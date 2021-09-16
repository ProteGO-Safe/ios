//
//  OpenerService.swift
//  safesafe
//
//  Created by Adam Tokarczyk on 23/06/2021.
//

import UIKit

protocol OpenerServiceType: AnyObject {
    func open(_ route: OpenerService.Route)
}


final class OpenerService: OpenerServiceType {
    
    // MARK: - Properties
    
    private let appSharedPreferences: UIApplication
    
    enum Route {
        case settingsUrl
        case smsUrl(number: String, message: String)
        
        var url: URL {
            switch self {
            case .settingsUrl:
                return URL(string: UIApplication.openSettingsURLString)!
            case .smsUrl(let number, let message):
                return URL(string: "sms:\(number)&body=\(message)")!
            }
        }
    }
    
    // MARK: - Life Cycle
    
    public init(appSharedPreferences: UIApplication = .shared) {
        self.appSharedPreferences = appSharedPreferences
    }
    
    // MARK: - Methods
    
    func open(_ route: Route) {
        if appSharedPreferences.canOpenURL(route.url) {
            appSharedPreferences.open(route.url, completionHandler: nil)
        } else {
            console("Can't open url: \(route.url)")
        }
    }
}
