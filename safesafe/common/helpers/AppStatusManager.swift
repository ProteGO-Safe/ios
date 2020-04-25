//
//  AppStatusManager.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 22/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import CoreBluetooth
import PromiseKit
 
protocol AppStatusManagerProtocol {
    
    var currentAppStatus: Promise<AppStatus> { get }
    var appStatusJson: Promise<String> { get }
    
}

final class AppStatusManager: AppStatusManagerProtocol {
    
    // MARK: - Properties
    
    private let bluetraceManager: BluetraceManager
    private let notificationManager: NotificationManagerProtocol
    
    private var isBluetoothServiceOn: Bool {
        AppManager.instance.isBluetraceAllowed
    }

    var currentAppStatus: Promise<AppStatus> {
        Promise<AppStatus> { [weak self] seal in
            guard let self = self else {
                seal.reject(InternalError.deinitialized)
                return
            }
            
            firstly {
                when(fulfilled: self.notificationManager.currentStatus(), self.bluetraceManager.isBluetoothEnabled)
            }.done { notificationStatus, _ in
                seal.fulfill(AppStatus(servicesStatus: .init(
                    isBluetoothOn: self.bluetraceManager.isBluetoothAuthorized(),
                    isNotificationEnabled: notificationStatus == .authorized,
                    isBluetoothServiceOn: self.isBluetoothServiceOn)
                ))
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
    
    init(
        bluetraceManager: BluetraceManager,
        notificationManager: NotificationManagerProtocol
    ) {
        self.bluetraceManager = bluetraceManager
        self.notificationManager = notificationManager
    }
    
}
