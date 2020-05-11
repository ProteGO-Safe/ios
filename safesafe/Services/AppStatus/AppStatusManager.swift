//
//  AppStatusManager.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 22/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import PromiseKit

protocol AppStatusManagerProtocol {
    
    var currentAppStatus: Promise<AppStatus> { get }
    var appStatusJson: Promise<String> { get }
    
}

final class AppStatusManager: AppStatusManagerProtocol {
    
    // MARK: - Properties
    
    private let notificationManager: NotificationManagerProtocol
    
    var currentAppStatus: Promise<AppStatus> {
        Promise<AppStatus> { seal in
            
            firstly {
                when(fulfilled: Permissions.instance.state(for: .notifications), Permissions.instance.state(for: .bluetooth))
            }.done { notificationStatus, bluetoothStatus in
                seal.fulfill(AppStatus(servicesStatus: .init(isNotificationEnabled: notificationStatus == .authorized)))
            }.catch { error in
                console(error, type: .error)
                seal.reject(error)
            }
        }
    }
    
    var appStatusJson: Promise<String> {
        Promise<String> { [weak self] seal in
            guard let self = self else {
                seal.reject(InternalError.deinitialized)
                return
            }
            
            self.currentAppStatus
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
