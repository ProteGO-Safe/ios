//
//  NotificationsPermission.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 26/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import UserNotifications
import PromiseKit

final class NotificationsPermission: PermissionType {
    func state(shouldAsk: Bool) -> Promise<Permissions.State> {
        if shouldAsk {
            return readState().then { currentState -> Promise<Permissions.State> in
                if currentState == .neverAsked {
                    return self.askForPermissions()
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
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    seal.fulfill(.authorized)
                case .denied:
                    seal.fulfill(.rejected)
                case .notDetermined:
                    seal.fulfill(.neverAsked)
                @unknown default:
                    seal.fulfill(.unknown)
                }
            }
        }
    }
    
    private func askForPermissions() -> Promise<Permissions.State> {
        return Promise { seal in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                seal.fulfill(granted ? .authorized : .rejected)
            }
        }
    }
}
