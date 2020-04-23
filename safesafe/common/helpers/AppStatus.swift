//
//  AppStatus.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 22/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

struct AppStatus: Codable {
    
    let isBluetoothSupported = true
    let isLocationEnabled = true
    let isBatteryOptimizationOn = true
    
    var isBluetoothOn: Bool
    var isNotificationEnabled: Bool
    var isBluetoothServiceOn: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isBluetoothSupported = "isBtSupported"
        case isLocationEnabled
        case isBatteryOptimizationOn
        case isBluetoothOn = "isBtOn"
        case isNotificationEnabled
        case isBluetoothServiceOn = "isBtServiceOn"
    }
    
}
