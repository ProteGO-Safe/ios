//
//  EnableServicesResponse.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 17/05/2020.
//

import Foundation

struct EnableServicesResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case enableBluetooth = "enableBt"
        case enableExposureNotificationService
        case enableNotification
    }
    
    let enableExposureNotificationService: Bool?
    let enableBluetooth: Bool?
    let enableNotification: Bool?
}
