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
    #elseif STAGE
    static private let configPlistName = "Config-stage"
    #elseif LIVE
    static private let configPlistName = "Config-live"
    #elseif LIVE_ADHOC
    static private let configPlistName = "Config-live"
    #endif
    
    static let `default` = ConfigManager(plistName: configPlistName)
    
    private enum Key {
        // Bluetooth settings
        static let bluetooth = "Bluetooth" // Dictionary
        static let serviceUUID = "SERVICE_UUID" // String
        static let v2CharacteristicId = "V2_CHARACTERISTIC_ID" // String
        static let orgId = "ORG_ID" // String
        static let protocolVersion = "PROTOCOL_VERSION" // Int
        static let centralScanInterval = "CENTRAL_SCAN_INTERVAL" // Int
        static let centralScanDuration = "CENTRAL_SCAN_DURATION" // Int
        static let dataExpirationDays = "DATA_EXPIRATION_DAYS" // Int
        
        // PWA Settings
        static let pwa = "PWA" // Dictionary
        static let host = "HOST" // String
        static let scheme = "SCHEME" // String
     }
    
    private let settings: [String: Any]
    
    init(plistName: String) {
        guard
            let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            fatalError("Can't find \(plistName).plist")
        }
        
        settings = plist
    }
    
    private func value<T>(for key: String, dictionary: [String: Any]) -> T {
        guard let dictValue = dictionary[key] as? T else {
            fatalError("Can't read value [\(T.self)] for \(key)")
        }
        
        return dictValue
    }
    
}

// Bluetooth
extension ConfigManager {
    private var bluetoothSettings: [String: Any] {
        guard let dictionary = settings[Key.bluetooth] as? [String: Any] else {
            fatalError("Can't read \(Key.bluetooth) from plist")
        }
        
        return dictionary
    }
    
    var serviceUUID: String {
        return value(for: Key.serviceUUID, dictionary: bluetoothSettings)
    }
    
    var v2CharacteristicId: String {
         return value(for: Key.v2CharacteristicId, dictionary: bluetoothSettings)
    }
    
    var orgId: String {
        return value(for: Key.orgId, dictionary: bluetoothSettings)
    }
    
    var protocolVersion: Int {
        return value(for: Key.protocolVersion, dictionary: bluetoothSettings)
    }
    
    var centralScanInterval: Int {
        return value(for: Key.centralScanInterval, dictionary: bluetoothSettings)
    }
    
    var centralScanDuration: Int {
        return value(for: Key.centralScanDuration, dictionary: bluetoothSettings)
    }
    
    var dataExpirationDays: Int {
        return value(for: Key.dataExpirationDays, dictionary: bluetoothSettings)
    }
}

// PWA
extension ConfigManager {
    private var pwaSettings: [String: Any] {
        guard let dictionary = settings[Key.pwa] as? [String: Any] else {
            fatalError("Can't read \(Key.pwa) from plist")
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
