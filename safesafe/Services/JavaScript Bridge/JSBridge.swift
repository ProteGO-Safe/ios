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
    
    // MARK: - Constants
    
    enum BridgeDataType: Int {
        case dailyTopicUnsubscribe = 1
        case notification = 2
        case applicationLifecycle = 11
        case notificationsPermission = 35
        case serviceStatus = 51
        case setServices = 52
        case clearData = 37
        case uploadTemporaryExposureKeys = 43
        case exposureList = 61
        case appVersion = 62
    }
    
    enum SendMethod: String, CaseIterable {
        case bridgeDataResponse = "bridgeDataResponse"
        case onBridgeData = "onBridgeData"
    }
    
    private enum ReceivedMethod: String, CaseIterable {
        case setBridgeData = "setBridgeData"
        case bridgeDataRequest = "bridgeDataRequest"
        case getBridgeData = "getBridgeData"
    }
    
    private enum Key {
        static let timestamp = "timestamp"
        static let data = "data"
        static let requestId = "requestId"
        static let type = "type"
    }
    
    // MARK: - Properties
    
    private let jsonDecoder = JSONDecoder()
    private let serviceStatusManager: ServiceStatusManagerProtocol
    private var exposureNotificationBridge: ExposureNotificationJSProtocol?
    private var diagnosisKeysUploadService: DiagnosisKeysUploadServiceProtocol?
    
    private var isServicSetting: Bool = false
    private var currentDataType: BridgeDataType?
    private var notificationPayload: String?
    
    private weak var webView: WKWebView?
    private var controller: WKUserContentController?
    
    var contentController: WKUserContentController {
        let controller = self.controller ?? WKUserContentController()
        for method in ReceivedMethod.allCases {
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
    
    func bridgeDataResponse(type: BridgeDataType, body: String, requestId: String, completion: ((Any?, Error?) -> ())? = nil) {
        DispatchQueue.main.async {
            guard let webView = self.webView else {
                console("WebView not registered. Please use `register(webView: WKWebView)` before use this method", type: .warning)
                return
            }
            let method = "\(SendMethod.bridgeDataResponse.rawValue)('\(body)','\(type.rawValue)','\(requestId)')"
            console(method)
            webView.evaluateJavaScript(method, completionHandler: completion)
        }
    }
    
    func onBridgeData(type: BridgeDataType, body: String, completion: ((Any?, Error?) -> ())? = nil) {
        DispatchQueue.main.async {
            guard let webView = self.webView else {
                console("WebView not registered. Please use `register(webView: WKWebView)` before use this method", type: .warning)
                return
            }
            let method = "\(SendMethod.onBridgeData.rawValue)(\(type.rawValue),'\(body)')"
            webView.evaluateJavaScript(method, completionHandler: completion)
        }
    }
    
    private func encodeToJSON<T>(_ encodable: T) -> String? where T: Encodable {
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
        guard let method = ReceivedMethod(rawValue: message.name) else {
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
            let type = object[Key.type] as? Int,
            let bridgeDataType = BridgeDataType(rawValue: type)
            else {
                return
        }
        
        let jsonString = object[Key.data] as? String
        switch bridgeDataType {
        case .dailyTopicUnsubscribe:
            unsubscribeFromTopic(jsonString: jsonString, type: bridgeDataType)
            
        case .notificationsPermission:
            currentDataType = bridgeDataType
            notificationsPermission(jsonString: jsonString, type: bridgeDataType)
            
        case .uploadTemporaryExposureKeys:
            uploadTemporaryExposureKeys(jsonString: jsonString)
            
        case .setServices:
            currentDataType = bridgeDataType
            servicesPermissions(jsonString: jsonString, type: bridgeDataType)
        case .clearData:
            RealmLocalStorage.clearAll()
        default:
            console("Not managed yet", type: .warning)
        }
    }
    
    private func getBridgeDataManage(body: Any) {
        guard
            let requestData = body as? [String: Any],
            let requestId = requestData[Key.requestId] as? String,
            let type = requestData[Key.type] as? Int,
            let bridgeDataType = BridgeDataType(rawValue: type)
            else {
                return
        }
        
        switch bridgeDataType {
        case .notification:
            notificationGetBridgeDataResponse(requestID: requestId)
            
        case .serviceStatus:
            serviceStatusGetBridgeDataResponse(requestID: requestId)
            
        case .exposureList:
            exposureListGetBridgeDataResponse(requestID: requestId)
            
        case .appVersion:
            applicationVersionGetBridgeDataResponse(requestID: requestId)
            
        default:
            return
        }
    }
}

// MARK: - getBridgeData handling
private extension JSBridge {
    
    func notificationGetBridgeDataResponse(requestID: String) {
        guard let jsonData = NotificationManager.shared.stringifyUserInfo() else {
            return
        }
        
        bridgeDataResponse(type: .notification, body: jsonData, requestId: requestID) { _, error in
            NotificationManager.shared.clearUserInfo()
            if let error = error {
                console(error, type: .error)
            }
        }
    }
    
    func serviceStatusGetBridgeDataResponse(requestID: String) {
        serviceStatusManager.serviceStatusJson(delay: .zero)
            .done { [weak self] json in
                self?.bridgeDataResponse(type: .serviceStatus, body: json, requestId: requestID) { _ ,error in
                    if let error = error {
                        console(error, type: .error)
                    }
                }
        }.catch { error in
            console(error, type: .error)
        }
    }
    
    func exposureListGetBridgeDataResponse(requestID: String) {
        exposureNotificationBridge?.getExposureSummary()
            .done { [weak self] summary in
                if let body = self?.encodeToJSON(summary) {
                    self?.bridgeDataResponse(type: .exposureList, body: body, requestId: requestID) { _, error in
                        if let error = error {
                            console(error, type: .error)
                        }
                    }
                }
        }.catch {
            console($0, type: .error)
        }
    }
    
    func applicationVersionGetBridgeDataResponse(requestID: String) {
        guard let version = UIApplication.appVersion  else { return }
        let responseModel = ApplicationVersionResponse(appVersion: version)
        
        guard let responseData = encodeToJSON(responseModel) else { return }
        
        bridgeDataResponse(type: .appVersion, body: responseData, requestId: requestID)
    }
}

// MARK: - onBridgeData handling
private extension JSBridge {
    func unsubscribeFromTopic(jsonString: String?, type: BridgeDataType) {
        guard let model: SurveyFinishedResponse = jsonString?.jsonDecode(decoder: jsonDecoder) else { return }
        
        NotificationManager.shared.unsubscribeFromDailyTopic(timestamp: model.timestamp)
    }
    
    // This one needs refactoring because it's ugly, it works but it's ugly :P
    //
    func servicesPermissions(jsonString: String?, type: BridgeDataType) {
        isServicSetting = true
        guard let model: EnableServicesResponse = jsonString?.jsonDecode(decoder: jsonDecoder) else { return }
        
        // Manage Notifications
        if model.enableNotification == true {
            isServicSetting = false
            notificationsPermission(jsonString: jsonString, type: type)
            return
        }
        
        // Manage COVID ENA
        if let enableExposureNotification = model.enableExposureNotificationService {
            exposureNotificationBridge?.enableService(enable: enableExposureNotification)
                .done { [weak self] _ in
                    self?.sendAppStateJSON(type: .serviceStatus)
                    self?.isServicSetting = false
            }
            .catch(policy: .allErrors) { error in
                console(error, type: .error)
            }
        }
    }
    
    func notificationsPermission(jsonString: String?, type: BridgeDataType) {
        Permissions.instance.state(for: .notifications)
            .then { state -> Promise<Permissions.State> in
                switch state {
                case .neverAsked:
                    return Permissions.instance.state(for: .notifications, shouldAsk: true)
                case .authorized:
                    return Promise.value(state)
                case .rejected:
                    guard let rootViewController = self.webView?.window?.rootViewController else {
                        throw InternalError.nilValue
                    }
                    return Permissions.instance.settingsAlert(for: .notifications, on: rootViewController).map { _ in Permissions.State.unknown }
                default:
                    return Promise.value(.unknown)
                }
        }
        .done { state in
            let didAuthorizeAPN = StoredDefaults.standard.get(key: .didAuthorizeAPN) ?? false
            if state == .authorized && !didAuthorizeAPN {
                StoredDefaults.standard.set(value: true, key: .didAuthorizeAPN)
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            self.sendAppStateJSON(type: .serviceStatus)
            self.isServicSetting = false
        }
        .catch { error in
            Assertion.failure(error.localizedDescription)
        }
    }
    
    func sendExposureList() {
        exposureNotificationBridge?.getExposureSummary()
            .done { [weak self] summary in
                if let body = self?.encodeToJSON(summary) {
                    self?.onBridgeData(type: .exposureList, body: body) { _, error in
                        if let error = error {
                            console(error, type: .error)
                        }
                    }
                }
            }.catch {
                console($0, type: .error)
        }
    }
    
    func uploadTemporaryExposureKeys(jsonString: String?) {
        guard let response: UploadTemporaryExposureKeysResponse = jsonString?.jsonDecode(decoder: jsonDecoder)
            else { return }
        
        diagnosisKeysUploadService?.upload(usingAuthCode: response.pin).done {
            self.send(.success)
        }.catch { error in
            if !(error is InternalError) {
                self.send(.failure)
            } else {
                self.send(.other)
            }
            
        }
    }
    
    func send(_ status: UploadTemporaryExposureKeysStatus) {
        guard let result = self.encodeToJSON(UploadTemporaryExposureKeysStatusResult(result: status))
            else { return }
        
        self.onBridgeData(type: .uploadTemporaryExposureKeys, body: result)
    }
    
    
    func sendAppStateJSON(type: BridgeDataType) {
        serviceStatusManager.serviceStatusJson(delay: .zero)
            .done { json in
                console(json)
                self.onBridgeData(type: type, body: json)
        }
        .ensure {
            self.currentDataType = nil
        }
        .catch { error in
            console(error, type: .error)
        }
    }
    
}

private extension JSBridge {
    
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
