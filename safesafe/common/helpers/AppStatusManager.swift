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
            }.done { notificationStatus, isBluetoothOn in
                seal.fulfill(AppStatus(servicesStatus: .init(
                    isBluetoothOn: isBluetoothOn,
                    isNotificationEnabled: notificationStatus == .authorized,
                    isBluetoothServiceOn: self.isBluetoothServiceOn)
                ))
            }.catch { error in
                console(error, type: .error)
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
