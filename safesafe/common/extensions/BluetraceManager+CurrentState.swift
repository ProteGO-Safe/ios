//
//  BluetraceManager+CurrentState.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 23/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import CoreBluetooth
import PromiseKit

extension BluetraceManager {
    
    var isBluetoothEnabled: Promise<Bool> {
        Promise<Bool> { [weak self] seal in
            guard let self = self else {
                seal.reject(InternalError.deinitialized)
                return
            }
            
            guard
                self.state == .unknown,
                self.isBluetoothAuthorized()
            else {
                seal.fulfill(self.isBluetoothOn())
                return
            }
            
            self.bluetoothDidUpdateStateCallback = { _ in
                seal.fulfill(self.isBluetoothOn())
            }
        }
    }
    
    private var state: CBManagerState {
        switch self.getCentralStateText() {
        case "poweredOff":
            return .poweredOff
        case "poweredOn":
            return .poweredOn
        case "resetting":
            return .resetting
        case "unauthorized":
            return .unauthorized
        case "unsupported":
            return .unsupported
        default:
            return .unknown
        }
    }
    
}
