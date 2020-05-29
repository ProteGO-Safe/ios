//
//  ExposureNotificationStatus.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 25/05/2020.
//

import Foundation
import PromiseKit
import ExposureNotification

@available(iOS 13.5, *)
final class ExposureNotificationStatus: ExposureNotificationStatusProtocol {
    
    private let service: ExposureServiceProtocol
    
    init(service: ExposureServiceProtocol) {
        self.service = service
    }
    
    var status: Promise<ServicesResponse.Status.ExposureNotificationStatus> {
        return service.activateManager()
            .map {
                if ENManager.authorizationStatus != .authorized {
                    return .off
                } else {
                    switch $0 {
                    case .active: return .on
                    case .bluetoothOff, .disabled: return .off
                    default: return .restricted
                    }
                }
        }
    }
    
    var isBluetoothOn: Promise<Bool> {
        return service.activateManager()
            .map {
                switch $0 {
                case .bluetoothOff: return false
                default: return true
                }
        }
    }
}

final class ExposureNotificationStatusMock: ExposureNotificationStatusProtocol {
    var status: Promise<ServicesResponse.Status.ExposureNotificationStatus> = .value(.restricted)
    var isBluetoothOn: Promise<Bool> = .value(false)
}
