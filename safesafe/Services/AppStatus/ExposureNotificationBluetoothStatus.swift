//
//  ExposureNotificationStatus.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 17/05/2020.
//

import Foundation
import ExposureNotification
import PromiseKit


final class ExposureNotificationBluetoothStatus {
    
    @available(iOS 13.5, *)
    private static var manager: ENManager?
    
    static var status: Promise<Bool> {
        if #available(iOS 13.5, *) {
            manager = ENManager()
            return Promise { seal in
                manager?.activate(completionHandler: { _ in
                    guard let manager = manager else {
                        return seal.reject(InternalError.deinitialized)
                    }
                    
                    switch manager.exposureNotificationStatus {
                    case .bluetoothOff: seal.fulfill(false)
                    default: seal.fulfill(true)
                    }
                    
                    manager.invalidate()
                })
            }
        } else {
            return .value(false)
        }
    }
}
