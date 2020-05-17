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
                    Permissions.instance.state(for: .exposureNotification),
                    Permissions.instance.state(for: .bluetooth)
                )
            }.done { notificationStatus, exposureStatus, bluetoothStatus in
                let status = ServicesResponse.Status(
                    exposureNotificationStatus: exposureStatus.asJSBridgeStatus,
                    isBluetoothOn: bluetoothStatus == .authorized,
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
                    guard
                        let data = try? JSONEncoder().encode(status),
                        let json = String(data: data, encoding: .utf8)
                        else {
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
