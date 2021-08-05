//
//  Permissions.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 26/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import PromiseKit

final class Permissions {
    
    static let instance = Permissions()
    
    private let notifications: PermissionType = NotificationsPermission()
    private let exposureNotifiaction: PermissionType = ExposureNotificationPermission()
    private let openerService: OpenerServiceType = OpenerService()
    
    enum Permission {
        case notifications
        case exposureNotification
        case bluetooth
    }
    
    enum State {
        case neverAsked // unauthorized
        case rejected
        case authorized
        case cantUse // (restricted): This application is not authorized to use bluetooth. The user cannot change this application’s status, possibly due to active restrictions such as parental controls being in place.
        case unknown
    }
    
    enum AlertAction {
        case cancel
        case settings
        case skip
    }
    
    private init() {}
    
    
    /// Get sevice authorization state
    /// - Parameters:
    ///   - permission: name of the service we want to ask for
    ///   - shouldAsk: if state is `neverAsked` and this flag is `true`, the authorization alert will be displayed for user. If flag is `false` only authorization state will be returned.
    /// Default value is `false`
    func state(for permission: Permission, shouldAsk: Bool = false) -> Promise<State> {
        switch permission {
        case .notifications:
            return notifications.state(shouldAsk: shouldAsk)
        case .exposureNotification:
            return exposureNotifiaction.state(shouldAsk: shouldAsk)
        default: return .value(.unknown)
        }
    }
    
    func settingsAlert(for permission: Permission, on viewController: UIViewController) -> Guarantee<AlertAction> {
        return Guarantee { fulfill in
            let (title, body) = self.alertCopy(for: permission)
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "CANCEL_BUTTON_TITLE".localized(), style: .cancel) { _ in
                fulfill(.cancel)
            }
            let settingsAction = UIAlertAction(title: "SETTINGS_TITLE".localized(), style: .default) { _ in
                self.openerService.open(.settingsUrl)
                fulfill(.settings)
            }
            alert.addAction(cancelAction)
            alert.addAction(settingsAction)
            
            DispatchQueue.main.async {
                viewController.present(alert, animated: true)
            }
        }
    }
    
    func choiceAlert(for permission: Permission, on viewController: UIViewController) -> Promise<AlertAction> {
        return Promise { seal in
            let (title, body) = self.choiceAlertCopy(for: permission)
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "SKIP_BUTTON_TITLE".localized(), style: .cancel) { _ in
                seal.fulfill(.skip)
            }
            let settingsAction = UIAlertAction(title: "SETTINGS_TITLE".localized(), style: .default) { _ in
                self.openerService.open(.settingsUrl)
                seal.fulfill(.settings)
            }
            alert.addAction(cancelAction)
            alert.addAction(settingsAction)
            
            DispatchQueue.main.async {
                viewController.present(alert, animated: true)
            }
        }
    }
   
    private func choiceAlertCopy(for permission: Permission) -> (title: String, body: String) {
        switch permission {
        case .exposureNotification:
            return (title: "EN_MONITORING_OFF_ALERT_TITLE".localized(), body: "EN_MONITORING_OFF_ALERT_TITLE".localized())
        case .bluetooth:
            return (title: "BT_MODULE_OFF_ALERT_TITLE".localized(), body: "BT_MODULE_OFF_ALERT_MESSAGE".localized())
        default:
            return (title: "", body: "")
        }
    }
    
    private func alertCopy(for permission: Permission) -> (title: String, body: String) {
        switch permission {
        case .notifications:
            return (title: "APNS_OFF_ALERT_TITLE".localized(), body: "APNS_OFF_ALERT_MESSAGE".localized())
        case .exposureNotification:
            return (title: "COVID TITLE", body: "COVID MESSAGE")
        case .bluetooth:
            return (title: "BLUETOOTH TITLE", body: "BLUETOOTH MESSAGE")
        }
    }
}

