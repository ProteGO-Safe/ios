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
    
    override private init() {}
    
    func register(webView: WKWebView)  {
        self.webView = webView
    }
    
    func storePayload(_ payload: Any) {
        
    }
    
    func bridgeDataResponse(type: BridgeDataType, body: String, requestId: String, completion: ((Any?, Error?) -> ())? = nil) {
        guard let webView = webView else {
            console("WebView not registered. Please use `register(webView: WKWebView)` before use this method", type: .warning)
            return
        }
        let method = "\(SendMethod.bridgeDataResponse.rawValue)('\(body)','\(type.rawValue)','\(requestId)')"
        webView.evaluateJavaScript(method, completionHandler: completion)
    }
    
    func onBridgeData(type: BridgeDataType, body: String, completion: ((Any?, Error?) -> ())? = nil) {
        guard let webView = webView else {
            console("WebView not registered. Please use `register(webView: WKWebView)` before use this method", type: .warning)
            return
        }
        
        let method = "\(SendMethod.onBridgeData.rawValue)('\(body)','\(type.rawValue)')"
        webView.evaluateJavaScript(method, completionHandler: completion)
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
            bluetoothPermission(jsonString: jsonString, type: bridgeDataType)
        case .notificationsPermission:
            notificationsPermission(jsonString: jsonString, type: bridgeDataType)
        case .opentraceToggle:
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
                self?.onBridgeData(type: .appStatus, body: json)
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
        // BluetraceManager.shared.turnOn()
        
        appStatusManager.appStatusJson
            .done { [weak self] json in
                self?.onBridgeData(type: type, body: json)
            }.catch { error in
                console(error, type: .error)
            }
    }
    
    func notificationsPermission(jsonString: String?, type: BridgeDataType) {
        NotificationManager.shared.registerForRemoteNotifications()
            .done { [weak self] isRegistered in
                if isRegistered {
                    self?.appStatusManager.appStatusJson
                    .done { json in
                        self?.onBridgeData(type: type, body: json)
                    }.catch { error in
                        console(error, type: .error)
                    }
                } else {
                    self?.permissionRejected(for: .notification)
                }
            }
    }
    
    func opentraceToggle(jsonString: String?, type: BridgeDataType) {
        // turn on / off BlueTrace peripheral and central
        guard let model: OpentraceToggleResponse = jsonString?.jsonDecode(decoder: jsonDecoder) else { return }
        
        if model.enableBtService {
            BluetraceManager.shared.turnOn()
        } else {
            BluetraceManager.shared.turnOff()
        }
        
        appStatusManager.appStatusJson
            .done { [weak self] json in
                self?.onBridgeData(type: type, body: json)
            }.catch { error in
                console(error, type: .error)
            }
    }
    
    func permissionRejected(for service: RejectedService) {
        let response = RejectedServiceResponse(rejectService: service)
        
        guard
            let data = try? JSONEncoder().encode(response),
            let json = String(data: data, encoding: .utf8)
        else {
            return
        }
        
        onBridgeData(type: .permissionRejected, body: json)
    }
}
