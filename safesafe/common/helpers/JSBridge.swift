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
        case notification
        case userIds
    }
    
    enum SendMethod: String, CaseIterable {
        case setBridgeData = "setBridgeData"
    }
    
    private enum ReceivedMethod: String, CaseIterable {
        case getNotification = "getNotification"
    }
    
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
    
    override private init() {}
    
    func register(webView: WKWebView)  {
        self.webView = webView
    }
    
    func setBridgeData(type: BridgeDataType, body: String, completion: ((Any?, Error?) -> ())? = nil) {
        guard let webView = webView else {
            console("WebView not registered. Please use `register(webView: WKWebView)` before use this method", type: .warning)
            return
        }
        let method = "\(SendMethod.setBridgeData.rawValue)('\(type.rawValue)', '\(body)')"
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
        case .getNotification:
            console(message.body)
        }
    }
}
