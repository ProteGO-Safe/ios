//
//  ExposureNotificationStatus.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 17/05/2020.
//

import Foundation
import ExposureNotification
import PromiseKit


final class ExposureNotificationStatus {
    
    @available(iOS 13.5, *)
    private static var manager: ENManager?
    
    static var status: Promise<ServicesResponse.Status.ExposureNotificationStatus> {
        if #available(iOS 13.5, *) {
            manager = ENManager()
            return Promise { seal in
                manager?.activate(completionHandler: { _ in
                    guard let manager = manager else {
                        return seal.reject(InternalError.deinitialized)
                    }
                    
                    if ENManager.authorizationStatus != .authorized {
                        seal.fulfill(.off)
                    } else {
                        switch manager.exposureNotificationStatus {
                        case .active: seal.fulfill(.on)
                        case .bluetoothOff, .disabled: seal.fulfill(.off)
                        default: seal.fulfill(.restricted)
                        }
                    }
                    
                    manager.invalidate()
                })
            }
        } else {
            return .value(.restricted)
        }
    }
}
