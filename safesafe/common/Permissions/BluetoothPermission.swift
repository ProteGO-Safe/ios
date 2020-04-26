//
//  BluetoothPermission.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 26/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import PromiseKit
import CoreBluetooth

private final class BluetoothDelegateProxy: NSObject, CBCentralManagerDelegate {
    let (promise, seal) = Promise<Permissions.State>.pending()
    private var retainCycle: BluetoothDelegateProxy?
    
    override init() {
        super.init()
        retainCycle = self
        
        promise.ensure {
            self.retainCycle = nil
        }
        .catch { error in
            console(error, type: .error)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 13.0, *) {
            switch central.authorization {
            case .allowedAlways:
                seal.fulfill(.authorized)
            case .denied:
                seal.fulfill(.rejected)
            case .notDetermined:
                seal.fulfill(.neverAsked)
            case .restricted:
                seal.fulfill(.cantUse)
            @unknown default:
                seal.fulfill(.unknown)
            }
        } else {
            // Until authorization is required since ios 13.x
            // we could always return .authorized for ios 12.x
            seal.fulfill(.authorized)
        }
    }
}

final class BluetoothPermission: PermissionType {
    
    private var proxy = BluetoothDelegateProxy()
    private var centralManager: CBCentralManager?
    
    func state(shouldAsk: Bool) -> Promise<Permissions.State> {
        if shouldAsk {
            return readState()
                .then { currentState -> Promise<Permissions.State> in
                    if currentState == .neverAsked {
                        self.centralManager = CBCentralManager(delegate: self.proxy, queue: nil)
                        return self.proxy.promise
                            .then { state -> Promise<Permissions.State> in
                                self.centralManager = nil
                                return Promise.value(state)
                        }
                    } else {
                        return Promise.value(currentState)
                    }
            }
        } else {
            return readState()
        }
    }
    
    private func readState() -> Promise<Permissions.State> {
        return Promise { seal in
            if #available(iOS 13.1, *) {
                switch CBManager.authorization {
                case .allowedAlways:
                    seal.fulfill(.authorized)
                case .denied:
                    seal.fulfill(.rejected)
                case .notDetermined:
                    seal.fulfill(.neverAsked)
                case .restricted:
                    seal.fulfill(.cantUse)
                @unknown default:
                    seal.fulfill(.unknown)
                }
            } else {
                // Until authorization is required since ios 13.1
                // we could always return .authorized for ios 13.0 and 12.x
                seal.fulfill(.authorized)
            }
        }
    }
}
