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
    
    override private init() {}
    
    private enum ReceivedMethod: String, CaseIterable {
        case getNotification = "getNotification"
    }
    
    enum SendMethod: String, CaseIterable {
        case postNotification = "postNotification"
    }
    
    private var controller: WKUserContentController?
    
    var contentController: WKUserContentController {
        let controller = self.controller ?? WKUserContentController()
        for method in ReceivedMethod.allCases {
            controller.add(self, name: method.rawValue)
        }
        
        self.controller = controller
        
        return controller
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
