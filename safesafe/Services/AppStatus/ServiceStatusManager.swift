//
//  AppStatusManager.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 22/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import PromiseKit

protocol ServiceStatusManagerProtocol {
    
    var currentServiceStatus: Promise<ServicesResponse> { get }
    var serviceStatusJson: Promise<String> { get }
    
}

final class ServiceStatusManager: ServiceStatusManagerProtocol {
    
    // MARK: - Properties
    
    private let notificationManager: NotificationManagerProtocol
    
    var currentServiceStatus: Promise<ServicesResponse> {
        Promise { seal in
            
            firstly {
                when(fulfilled:
                    Permissions.instance.state(for: .notifications),
                     ExposureNotificationStatus.status,
                     ExposureNotificationBluetoothStatus.status
                )
            }.done { notificationStatus, exposureStatus, bluetoothStatus in
                let status = ServicesResponse.Status(
                    exposureNotificationStatus: exposureStatus,
                    isBluetoothOn: bluetoothStatus,
                    isNotificationEnabled: notificationStatus == .authorized)
                seal.fulfill(ServicesResponse(status: status))
            }.catch { error in
                console(error, type: .error)
                seal.reject(error)
            }
        }
    }
    
    var serviceStatusJson: Promise<String> {
        Promise<String> { [weak self] seal in
            guard let self = self else {
                seal.reject(InternalError.deinitialized)
                return
            }
            
            self.currentServiceStatus
                .done { status in
                    guard let json = status.jsonString else {
                        seal.reject(InternalError.serializationFailed)
                        return
                    }
                    
                    seal.fulfill(json)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // MARK: - Life Cycle
    
    init(  notificationManager: NotificationManagerProtocol) {
        self.notificationManager = notificationManager
    }
}
