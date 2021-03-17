//
//  JSBridge.swift
//  safesafe Live
//
//  Created by Lukasz szyszkowski on 16/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import WebKit
import PromiseKit
import Network

final class JSBridge: NSObject {
    
    // MARK: - Properties
    
    let jsonDecoder = JSONDecoder()
    let serviceStatusManager: ServiceStatusManagerProtocol
    var exposureNotificationBridge: ExposureNotificationJSProtocol?
    var diagnosisKeysUploadService: DiagnosisKeysUploadServiceProtocol?
    var historicalDataWorker: HistoricalDataWorkerType?
    var dashboardWorker: DashboardWorkerType?
    var detailsWorker: DetailsWorkerType?
    
    var districtService: DistrictService?
    var freeTestService: FreeTestService?
    
    var isServicSetting: Bool = false
    var currentDataType: BridgeDataType?
    var notificationPayload: String?
    
    weak var webView: WKWebView?
    private var controller: WKUserContentController?
    
    var contentController: WKUserContentController {
        let controller = self.controller ?? WKUserContentController()
        for method in Constans.ReceivedMethod.allCases {
            controller.add(self, name: method.rawValue)
        }
        
        self.controller = controller
        
        return controller
    }
    
    // MARK: - Lifecycle
    
    init(with serviceStatusManager: ServiceStatusManagerProtocol) {
        self.serviceStatusManager = serviceStatusManager
        super.init()
        registerForAppLifecycleNotifications()
    }
    
    func register(webView: WKWebView)  {
        self.webView = webView
    }
    
    @available(iOS 13.5, *)
    func registerExposureNotification(
        with exposureNotificationBridge: ExposureNotificationJSProtocol,
        diagnosisKeysUploadService: DiagnosisKeysUploadServiceProtocol
    ) {
        self.exposureNotificationBridge = exposureNotificationBridge
        self.diagnosisKeysUploadService = diagnosisKeysUploadService
    }
    
    func register(districtService: DistrictService) {
        self.districtService = districtService
    }
    
    func register(freeTestService: FreeTestService) {
        self.freeTestService = freeTestService
        registerFreeTestObservers()
    }
    
    func register(historicalDataWorker: HistoricalDataWorkerType) {
        self.historicalDataWorker = historicalDataWorker
    }
    
    func register(dashboardWorker: DashboardWorkerType) {
        self.dashboardWorker = dashboardWorker
        self.dashboardWorker?.delegate = self
    }

    func register(detailsWorker: DetailsWorkerType) {
        self.detailsWorker = detailsWorker
    }
    
    func bridgeDataResponse(
        type: BridgeDataType,
        body: String?,
        requestId: String,
        completion: ((Any?, Error?) -> ())? = nil
    ) {
        DispatchQueue.main.async {
            guard let webView = self.webView else {
                console(
                    "WebView not registered. Please use `register(webView: WKWebView)` before use this method",
                    type: .warning
                )
                return
            }
            var method: String
            if let body = body {
                method = "\(Constans.SendMethod.bridgeDataResponse.rawValue)('\(body)','\(type.rawValue)','\(requestId)')"
            } else {
                method = "\(Constans.SendMethod.bridgeDataResponse.rawValue)('','\(type.rawValue)','\(requestId)')"
            }
            webView.evaluateJavaScript(method, completionHandler: completion)
        }
    }
    
    func onBridgeData(type: BridgeDataType, body: String, completion: ((Any?, Error?) -> ())? = nil) {
        DispatchQueue.main.async {
            guard let webView = self.webView else {
                console(
                    "WebView not registered. Please use `register(webView: WKWebView)` before use this method",
                    type: .warning
                )
                return
            }
            let method = "\(Constans.SendMethod.onBridgeData.rawValue)(\(type.rawValue),'\(body)')"
            webView.evaluateJavaScript(method, completionHandler: completion)
        }
    }
    
    func encodeToJSON<T>(_ encodable: T) -> String? where T: Encodable {
        do {
            let data = try JSONEncoder().encode(encodable)
            return String(data: data, encoding: .utf8)
        } catch {
            console(error)
            return nil
        }
    }
}

extension JSBridge: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let method = Constans.ReceivedMethod(rawValue: message.name) else {
            console("Not supported method: \(message.name)")
            return
        }
        
        switch method {
        case .setBridgeData:
            setBridgeDataManage(body: message.body)
        case .getBridgeData:
            getBridgeDataManage(body: message.body)
        default:
            Assertion.failure("Not managed yet \(method)")
        }
    }
    
    private func setBridgeDataManage(body: Any) {
        guard
            let object = body as? [String: Any],
            let type = object[Constans.Key.type] as? Int,
            let bridgeDataType = BridgeDataType(rawValue: type)
        else { return }
        
        let jsonString = object[Constans.Key.data] as? String
        switch bridgeDataType {
        case .dailyTopicUnsubscribe:
            unsubscribeFromTopic(jsonString: jsonString, dataType: bridgeDataType)
            
        case .notificationsPermission:
            currentDataType = bridgeDataType
            notificationsPermission(jsonString: jsonString, type: bridgeDataType)
            
        case .uploadTemporaryExposureKeys:
            uploadTemporaryExposureKeys(jsonString: jsonString)
            
        case .setServices:
            currentDataType = bridgeDataType
            servicesPermissions(jsonString: jsonString, dataType: bridgeDataType)
            
        case .systemLanguage:
            changeLanguage(jsonString: jsonString)
            
        case .clearData:
            StoredDefaults.standard.delete(key: .selectedLanguage)
            RealmLocalStorage.clearAll()
            
        case .requestAppReview:
            requestAppreview(jsonString: jsonString)
            
        case .historicalDataRemove:
            removeHistoricalData(jsonString: jsonString)
                        
        default:
            console("Not managed yet", type: .warning)
        }
    }
    
    private func getBridgeDataManage(body: Any) {
        guard
            let requestData = body as? [String: Any],
            let requestId = requestData[Constans.Key.requestId] as? String,
            let type = requestData[Constans.Key.type] as? Int,
            let bridgeDataType = BridgeDataType(rawValue: type)
        else { return }
        
        let jsonString = requestData[Constans.Key.data] as? String
        switch bridgeDataType {
            
        case .serviceStatus:
            serviceStatusGetBridgeDataResponse(requestID: requestId)
            
        case .exposureList:
            exposureListGetBridgeDataResponse(requestID: requestId)
            
        case .appVersion:
            applicationVersionGetBridgeDataResponse(requestID: requestId)
            
        case .systemLanguage:
            systemLanguageGetBridgeDataResponse(requestID: requestId)
        
        case .allDistricts:
            districtsList(requestID: requestId, dataType: bridgeDataType)
            
        case .districtsAPIFetch:
            districsAPIFetch(requestID: requestId, dataType: bridgeDataType)
            
        case .subscribedDistricts:
            subscribedDistricts(requestID: requestId, dataType: bridgeDataType)
            
        case .districtAction:
            manageDistrictObserved(jsonString: jsonString, requestId: requestId, dataType: bridgeDataType)
            
        case .freeTestPinUpload:
            freeTestPinUpload(jsonString: jsonString, requestID: requestId, dataType: bridgeDataType)
        
        case .freeTestSubscriptionInfo:
            freeTestSubscriptionInfo(jsonString: jsonString, requestID: requestId, dataType: bridgeDataType)
            
        case .freeTestPinCodeFetch:
            freeTestPinCodeFetch(requestID: requestId, dataType: bridgeDataType)
            
        case .clearExposureRisk:
            clearExposureRisk(requestID: requestId, dataType: bridgeDataType)
            
        case .historicalData:
            historicalData(requestID: requestId, dataType: bridgeDataType)
            
        case .dashboardStats:
            dashboardStats(requestID: requestId, dataType: bridgeDataType)
            
        case .covidStatsSubscription:
            covidStatsSubscription(requestID: requestId, dataType: bridgeDataType)
        
        case .agregatedStats:
            agregatedStats(requestID: requestId, dataType: bridgeDataType)
    
        case .setCovidStatsSubscription:
            setCovidStatsSubscription(jsonString: jsonString, requestID: requestId, dataType: bridgeDataType)

        case .detailsStats:
            detailsStats(requestID: requestId, dataType: bridgeDataType)
            
        default:
            console("Not managed yet", type: .warning)
        }
    }
    
    func debugSendExposureList() {
        sendExposureList(shouldDownload: false)
    }
}

extension JSBridge {
    func managePushNotificationAuthorization() {
        NotificationManager.shared
            .currentStatus()
            .done { status in
                switch status {
                case .notDetermined:
                    NotificationManager.shared.registerForNotifications(remote: false)
                case .denied:
                    NotificationsAlertManager().show(
                        type: .pushNotificationSettings
                    ) { action in
                        guard
                            let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                            action == .settings
                        else { return }

                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: nil)
                        }
                    }
                default: ()
                }
            }
    }
    
    func registerFreeTestObservers() {
        freeTestService?.jsOnSubsriptionInfo { [weak self] response in
            guard let data = response.jsonString else { return }
            
            self?.onBridgeData(type: .freeTestSubscriptionInfo, body: data)
        }
    }
    
    func registerForAppLifecycleNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc func applicationWillEnterForeground(notification: Notification) {
        sendAppStateJSON(type: .serviceStatus)
        guard let data = ApplicationLifecycleResponse(appicationState: .willEnterForeground).jsonString else {
            return
        }
        onBridgeData(type: .applicationLifecycle, body: data)
    }
    
    @objc func applicationDidEnterBackground(notification: Notification) {
        guard let data = ApplicationLifecycleResponse(appicationState: .didEnterBackground).jsonString else {
            return
        }
        onBridgeData(type: .applicationLifecycle, body: data)
    }
}

extension JSBridge: DeepLinkingDelegate {
    func runRoute(routeString: String) {
        onBridgeData(type: .route, body: routeString)
    }
}

extension JSBridge: DashboardWorkerDelegate {
    func onData(jsonString: String) {
        onBridgeData(type: .dashboardStats, body: jsonString)
    }
}

extension JSBridge {
    struct Constans {
        enum SendMethod: String, CaseIterable {
            case bridgeDataResponse = "bridgeDataResponse"
            case onBridgeData = "onBridgeData"
        }

        enum ReceivedMethod: String, CaseIterable {
            case setBridgeData = "setBridgeData"
            case bridgeDataRequest = "bridgeDataRequest"
            case getBridgeData = "getBridgeData"
        }

        enum Key {
            static let timestamp = "timestamp"
            static let data = "data"
            static let requestId = "requestId"
            static let type = "type"
        }
    }
}
