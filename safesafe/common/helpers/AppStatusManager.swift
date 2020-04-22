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
    
    private var isBluetoothServiceOn: Bool {
        AppManager.instance.isBluetraceAllowed
    }
    
    private var areNotificationsEnabled: Bool {
        NotificationManager.shared.didAuthorizeAPN
    }
    
    private var appStatus: AppStatus {
        AppStatus(
            isBluetoothOn: self.bluetraceManager.isBluetoothOn(),
            isNotificationEnabled: self.areNotificationsEnabled,
            isBluetoothServiceOn: self.isBluetoothServiceOn
        )
    }
    
    var currentAppStatus: Promise<AppStatus> {
        Promise<AppStatus> { [weak self] seal in
            guard let self = self else {
                seal.reject(InternalError.deinitialized)
                return
            }
            
            // If state is `unknown`, then CBCentralManager hasn't informed his delegate about the state yet
            // -> that's why we wait for the callback execution
            guard self.bluetraceManager.currentState == .unknown else {
                seal.fulfill(self.makeAppStatus())
                return
            }
            
            self.bluetraceManager.bluetoothDidUpdateStateCallback = { _ in
                seal.fulfill(self.makeAppStatus())
            }
        }
    }
    
    // MARK: - Life Cycle
    
    init(bluetraceManager: BluetraceManager) {
        self.bluetraceManager = bluetraceManager
    }
    
    // MARK: - Private methods
    
    private func makeAppStatus() -> AppStatus {
        AppStatus(
            isBluetoothOn: bluetraceManager.isBluetoothOn(),
            isNotificationEnabled: areNotificationsEnabled,
            isBluetoothServiceOn: isBluetoothServiceOn
        )
    }
    
}
