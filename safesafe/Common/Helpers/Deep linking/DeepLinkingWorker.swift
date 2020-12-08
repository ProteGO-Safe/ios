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
    func navigate(with url: URL)
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
        
        guard let jsonString = serialize(routeData: routeData) else { return }
        
        delegate?.runRoute(routeString: jsonString)
    }
    
    func navigate(with url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        let paths = components.path.split(separator: "/")
        
        guard let path = paths.first, paths.count == 1 else { return }
        
        var routeData: [String: Any] = ["name": path]
        
        if let queryItems = components.queryItems {
            routeData["params"] = routeParams(with: queryItems)
        }
        
        guard let jsonString = serialize(routeData: routeData) else { return }
        
        delegate?.runRoute(routeString: jsonString)
    }
    
    private func routeParams(with queryItems: [URLQueryItem]) -> [String: Any] {
        var params: [String: Any] = [:]
        
        for item in queryItems {
            params[item.name] = item.value
        }
        
        return params
    }
    
    private func serialize(routeData: [String: Any]) -> String? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: routeData, options: .fragmentsAllowed),
            let jsonString = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        
        return jsonString
    }
}
