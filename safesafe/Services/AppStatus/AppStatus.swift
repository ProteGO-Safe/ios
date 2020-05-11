//
//  AppStatus.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 22/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

struct AppStatus: Codable {
    
    var servicesStatus: ServicesStatus
    
    struct ServicesStatus: Codable {
        let isBluetoothSupported = true
        let isLocationEnabled = true
        let isBatteryOptimizationOn = true
        
        var isNotificationEnabled: Bool
        
        private enum CodingKeys: String, CodingKey {
            case isBluetoothSupported = "isBtSupported"
            case isLocationEnabled
            case isBatteryOptimizationOn
            case isNotificationEnabled
        }
    }
    
}
