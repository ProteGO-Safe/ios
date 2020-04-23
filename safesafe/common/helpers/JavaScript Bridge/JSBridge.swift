//
//  JSBridge.swift
//  safesafe Live
//
//  Created by Lukasz szyszkowski on 16/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import WebKit

final class JSBridge: NSObject {

    static let shared = JSBridge()
    
    enum BridgeDataType: Int {
        case notification = 1
        case userId = 2
        case appStatus = 31
    }
    
    enum SendMethod: String, CaseIterable {
        case bridgeDataResponse = "bridgeDataResponse"
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
        console(method)
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
        case .bridgeDataRequest:
            console(message.body)
        case .getBridgeData:
            getBridgeDataManage(body: message.body)
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

        switch bridgeDataType {
        case .notification:
            unsubscribeFromTopic(jsonString: object[Key.data] as? String)
        default:
            console("Not managed yet", type: .warning)
        }
    }
    
    private func getBridgeDataManage(body: Any) {
        guard
            let jsonData = NotificationManager.shared.stringifyUserInfo(),
            let requestData = body as? [String: Any],
            let requestId = requestData[Key.requestId] as? String
        else {
            return
        }
        
        bridgeDataResponse(type: .notification, body: jsonData, requestId: requestId) { _, error in
            NotificationManager.shared.clearUserInfo()
            if let error = error {
                console(error, type: .error)
            }
        }
    }
}

extension JSBridge {
    private func unsubscribeFromTopic(jsonString: String?) {
        guard
            let jsonString = jsonString,
            let data = jsonString.data(using: .utf8),
            let model = try? jsonDecoder.decode(SurveyFinishedResponse.self, from: data)
        else {
            return
        }
        
        NotificationManager.shared.unsubscribeFromDailyTopic(timestamp: model.timestamp)
    }
}
