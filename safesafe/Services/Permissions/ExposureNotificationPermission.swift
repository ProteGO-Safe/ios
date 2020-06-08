//
//  ExposureNotificationPermission.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 15/05/2020.
//

import Foundation
import PromiseKit
import ExposureNotification

final class ExposureNotificationPermission: PermissionType {

    func state(shouldAsk: Bool) -> Promise<Permissions.State> {
        return readState()
    }
    
    private func readState() -> Promise<Permissions.State> {
        if #available(iOS 13.5, *) {
            switch ENManager.authorizationStatus {
            case .authorized:
                return .value(.authorized)
            case .notAuthorized, .restricted:
                return .value(.rejected)
            case .unknown:
                return .value(.unknown)
            default:
                return .value(.cantUse)
            }
        } else {
            return .value(.cantUse)
        }
    }
}

extension Permissions.State {
    var asJSBridgeStatus: ServicesResponse.Status.ExposureNotificationStatus {
        switch self {
        case .authorized:
            return .on
        case .rejected, .neverAsked, .unknown:
            return .off
        default:
            return .restricted
        }
    }
}
