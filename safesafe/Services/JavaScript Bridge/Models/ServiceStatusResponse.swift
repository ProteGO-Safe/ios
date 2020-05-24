//
//  ServiceStatusResponse.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 15/05/2020.
//

import Foundation

struct ServicesResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case status = "servicesStatus"
    }
    
    let status: Status
    
    struct Status: Codable {
        enum CodingKeys: String, CodingKey {
            case isBluetoothOn = "isBtOn"
            case exposureNotificationStatus
            case isNotificationEnabled
        }
        
        let exposureNotificationStatus: ExposureNotificationStatus
        let isBluetoothOn: Bool
        let isNotificationEnabled: Bool
        
        enum ExposureNotificationStatus: Int, Codable {
            case on = 1
            case off
            case restricted
        }
    }
}
