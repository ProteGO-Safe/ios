//
//  DeepLinkingWorker.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 07/12/2020.
//

import Foundation

enum DeepLinkingScreens: String {
    case home
    case importantInformation
    case currentRestrictions
    case userData
    case privacyPolicy
    case daily
    case settings
    case warningInEurope
    case uploadHistoricalData
    case notificationsHistory
}

protocol DeepLinkingWorkerType {
    var delegate: DeepLinkingDelegate? { get set }
    func navigate(_ data: String)
    func navigate(to screen: DeepLinkingScreens, messageId: String?)
}

protocol DeepLinkingDelegate: class {
    func runRoute(routeString: String)
}

final class DeepLinkingWorker: DeepLinkingWorkerType {
    static let shared = DeepLinkingWorker()

    weak var delegate: DeepLinkingDelegate?
    
    private init() {}
    
    func navigate(_ data: String) {
        delegate?.runRoute(routeString: data)
    }
    
    func navigate(to screen: DeepLinkingScreens, messageId: String?) {
        var routeData: [String: Any] = ["name": screen.rawValue]
        var routeParams: [String: Any] = [:]
        routeParams[NotificationUserInfoParser.Key.uuid.rawValue] = messageId
        
        if !routeParams.isEmpty {
            routeData["params"] = routeParams
        }
        
        guard
            let data = try? JSONSerialization.data(withJSONObject: routeData, options: .fragmentsAllowed),
            let jsonString = String(data: data, encoding: .utf8)
        else {
            return
        }
        
        delegate?.runRoute(routeString: jsonString)
    }
}
