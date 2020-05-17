//
//  ExposureNotificationBluetoothPermissiom.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 17/05/2020.
//

import Foundation
import ExposureNotification
import PromiseKit

@available(iOS 13.5, *)
final class ExposureNotificationBluetoothPermission: PermissionType {
    
    private let manager = ENManager()
    
    func state(shouldAsk: Bool) -> Promise<Permissions.State> {
        return Promise { seal in
            manager.activate { [weak self] _ in
                guard let self = self else {
                    seal.reject(InternalError.deinitialized)
                    return
                }
                switch self.manager.exposureNotificationStatus {
                case .bluetoothOff:
                    console("Bluetooth off", type: .warning)
                case .active:
                    console("Active", type: .warning)
                case .disabled:
                    console("Disabled", type: .warning)
                case .restricted:
                    console("Restricted", type: .warning)
                case .unknown:
                    console("Unknown", type: .warning)
                default:
                    console("Other state", type: .warning)
                }
                self.manager.exposureNotificationStatus == .active ? seal.fulfill(.authorized) : seal.fulfill(.rejected)
                self.manager.invalidate()
            }
        }
    }
}
