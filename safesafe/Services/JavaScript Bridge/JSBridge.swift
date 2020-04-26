//
//  JSBridge.swift
//  safesafe Live
//
//  Created by Lukasz szyszkowski on 16/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import WebKit
import PromiseKit

final class JSBridge: NSObject {
    
    static let shared = JSBridge()
    
    enum BridgeDataType: Int {
        case notification = 1
        case userId = 2
        case appStatus = 31
        case bluetoothPermission = 33
        case notificationsPermission = 35
        case opentraceToggle = 36
        case permissionRejected = 37
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
    
    private weak var webView: WKWebView?
    private var currentDataType: BridgeDataType?
    private var notificationPayload: String?
    private var controller: WKUserContentController?
    private let jsonDecoder = JSONDecoder()
    
    var contentController: WKUserContentController {
        let controller = self.controller ?? WKUserContentController()
        for method in ReceivedMethod.allCases {
            controller.add(self, name: method.rawValue)
        }
        
        self.controller = controller
        
        return controller
    }
    
    private var appStatusManager: AppStatusManagerProtocol = AppStatusManager(
        bluetraceManager: BluetraceManager.shared,
        notificationManager: NotificationManager.shared
    )
    
    override private init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func register(webView: WKWebView)  {
        self.webView = webView
    }
    
    func storePayload(_ payload: Any) {
        
    }
    
    func bridgeDataResponse(type: BridgeDataType, body: String, requestId: String, completion: ((Any?, Error?) -> ())? = nil) {
        DispatchQueue.main.async {
            guard let webView = self.webView else {
                console("WebView not registered. Please use `register(webView: WKWebView)` before use this method", type: .warning)
                return
            }
            let method = "\(SendMethod.bridgeDataResponse.rawValue)('\(body)','\(type.rawValue)','\(requestId)')"
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
            assertionFailure("Not managed yet \(method)")
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
        case .notification:
            unsubscribeFromTopic(jsonString: jsonString, type: bridgeDataType)
        case .bluetoothPermission:
            currentDataType = bridgeDataType
            bluetoothPermission(jsonString: jsonString, type: bridgeDataType)
        case .notificationsPermission:
            currentDataType = bridgeDataType
            notificationsPermission(jsonString: jsonString, type: bridgeDataType)
        case .opentraceToggle:
            currentDataType = bridgeDataType
            opentraceToggle(jsonString: jsonString, type: bridgeDataType)
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
        case .appStatus:
            appStatusGetBridgeDataResponse(requestID: requestId)
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
    
    func appStatusGetBridgeDataResponse(requestID: String) {
        appStatusManager.appStatusJson
            .done { [weak self] json in
                self?.bridgeDataResponse(type: .appStatus, body: json, requestId: requestID)
        }.catch { error in
            console(error, type: .error)
        }
    }
    
}

// MARK: - onBridgeData handling
private extension JSBridge {
    func unsubscribeFromTopic(jsonString: String?, type: BridgeDataType) {
        guard let model: SurveyFinishedResponse = jsonString?.jsonDecode(decoder: jsonDecoder) else { return }
        
        NotificationManager.shared.unsubscribeFromDailyTopic(timestamp: model.timestamp)
    }
    
    func bluetoothPermission(jsonString: String?, type: BridgeDataType) {
        Permissions.instance.state(for: .bluetooth)
            .then { state -> Promise<Permissions.State> in
                switch state {
                case .neverAsked:
                    return Permissions.instance.state(for: .bluetooth, shouldAsk: true)
                case .authorized:
                    return Promise.value(state)
                case .rejected:
                    guard let rootViewController = self.webView?.window?.rootViewController else {
                        throw InternalError.nilValue
                    }
                    return Permissions.instance.settingsAlert(for: .bluetooth, on: rootViewController).map { _ in Permissions.State.unknown }
                default:
                    return Promise.value(.unknown)
                }
        }
        .done { state in
            if state == .authorized {
                self.sendAppStateJSON(type: type)
            } else if state == .rejected {
                BluetraceManager.shared.turnOff()
                self.permissionRejected(for: .bluetooth)
            }
        }
        .catch { error in
            assertionFailure(error.localizedDescription)
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
                self.sendAppStateJSON(type: type)
            } else if state == .rejected {
                BluetraceManager.shared.turnOff()
                self.permissionRejected(for: .bluetooth)
            }
        }
        .catch { error in
            assertionFailure(error.localizedDescription)
        }
    }
    
    func opentraceToggle(jsonString: String?, type: BridgeDataType) {
        // turn on / off BlueTrace peripheral and central
        guard let model: OpentraceToggleResponse = jsonString?.jsonDecode(decoder: jsonDecoder) else { return }
        
        Permissions.instance.state(for: .bluetooth)
            .done { state in
                if state == .authorized && model.enableBtService {
                    AppManager.instance.isBluetraceAllowed = true
                    BluetraceManager.shared.turnOn()
                    EncounterMessageManager.shared.authSetup()
                } else {
                    AppManager.instance.isBluetraceAllowed = false
                    BluetraceManager.shared.turnOff()
                }
        }
        .ensure {
            self.sendAppStateJSON(type: type)
        }
        .catch {_ in}
        
    }
    
    func permissionRejected(for service: RejectedService) {
        let response = RejectedServiceResponse(rejectedService: service)
        
        guard
            let data = try? JSONEncoder().encode(response),
            let json = String(data: data, encoding: .utf8)
            else {
                return
        }
        
        onBridgeData(type: .permissionRejected, body: json) { ret, error in
            if let error = error {
                console(error, type: .error)
            } else {
                console(ret)
            }
        }
    }
    
    private func sendAppStateJSON(type: BridgeDataType) {
        appStatusManager.appStatusJson
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
    
    @objc
    private func applicationDidBecomeActive(notification: Notification) {
        guard let type = currentDataType else {
            return
        }
        
        sendAppStateJSON(type: type)
    }
}
