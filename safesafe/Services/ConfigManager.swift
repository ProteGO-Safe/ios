//
//  ConfigManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 24/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

final class ConfigManager {
    
    #if DEV
    static private let configPlistName = "Config-dev"
    #elseif STAGE || STAGE_SCREENCAST || STAGE_DEBUG
    static private let configPlistName = "Config-stage"
    #elseif LIVE
    static private let configPlistName = "Config-live"
    #elseif LIVE_ADHOC
    static private let configPlistName = "Config-live"
    #elseif LIVE_DEBUG
    static private let configPlistName = "Config-live"
    #endif
    
    static let `default` = ConfigManager(plistName: configPlistName)
    
    private enum Key {
        // PWA Settings
        static let pwa = "PWA" // Dictionary
        static let host = "HOST" // String
        static let scheme = "SCHEME" // String
        
        // Exposure Notification
        static let exposureNotification = "EXPOSURE_NOTIFICATION" // Dictionary
        static let enGatBaseURL = "EN_GAT_BASE_URL" // String
        static let enUdkBaseURL = "EN_UDK_BASE_URL" // String
        static let enStorageURL = "EN_STORAGE_URL" // String

        // Base Url
        static let baseURL = "BASE_URL"
        
        // Free COVID Test
        static let freeTest = "FREE_TEST"
        static let freetTestBaseURL = "BASE_URL"
        
     }
    
    private let settings: [String: Any]
    
    init(plistName: String) {
        guard
            let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            Fatal.execute("Can't find \(plistName).plist")
        }
        
        settings = plist
    }
    
    private func value<T>(for key: String, dictionary: [String: Any]) -> T {
        guard let dictValue = dictionary[key] as? T else {
            Fatal.execute("Can't read value [\(T.self)] for \(key)")
        }
        
        return dictValue
    }
    
}

// PWA
extension ConfigManager {
    private var pwaSettings: [String: Any] {
        guard let dictionary = settings[Key.pwa] as? [String: Any] else {
            Fatal.execute("Can't read \(Key.pwa) from plist")
        }
        
        return dictionary
    }
    
    var pwaHost: String {
        return value(for: Key.host, dictionary: pwaSettings)
    }
    
    var pwaScheme: String {
        return value(for: Key.scheme, dictionary: pwaSettings)
    }
}

extension ConfigManager {

    // Exposure Notification
    private var enSettings: [String: Any] {
        guard let dictionary = settings[Key.exposureNotification] as? [String: Any] else {
            Fatal.execute("Can't read \(Key.exposureNotification) from plist")
        }
        
        return dictionary
    }
    
    private var freeTestSettings: [String: Any] {
        guard let dictionary = settings[Key.freeTest] as? [String: Any] else {
            Fatal.execute("Can't read \(Key.freeTest) from plist")
        }
        
        return dictionary
    }
    
    var enGatBaseURL: String {
        return value(for: Key.enGatBaseURL, dictionary: enSettings)
    }
    
    var enUdkBaseURL: String {
        return value(for: Key.enUdkBaseURL, dictionary: enSettings)
    }
    
    var enStorageURL: String {
        return value(for: Key.enStorageURL, dictionary: enSettings)
    }

    var baseURL: String {
        guard let baseURL = settings[Key.baseURL] as? String else {
            Fatal.execute("Can't read \(Key.baseURL) from plist")
        }
        return baseURL
    }
    
    var freeTestBaseURL: String {
        return value(for: Key.freetTestBaseURL, dictionary: freeTestSettings)
    }
}
