//
//  ExposureNotificationJSBridge.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 17/05/2020.
//

import Foundation
import PromiseKit
import ExposureNotification

protocol ExposureNotificationJSProtocol: class {
    func enableService(enable: Bool?) -> Promise<Void>
}

@available(iOS 13.5, *)
final class ExposureNotificationJSBridge: ExposureNotificationJSProtocol {
    
    private weak var manager: ExposureNotificationManagable?
    private weak var viewController: UIViewController?

    init(manager: ExposureNotificationManagable, viewController: UIViewController) {
        self.manager = manager
        self.viewController = viewController
    }
    
    func enableService(enable: Bool?) -> Promise<Void> {
        guard let manager = manager, let enable = enable else {
            return .value
        }
        
        if enable {
             return manager.activateManager()
                 .then { _ -> Promise<ENStatus> in
                     return manager.status()
             }
             .then { [viewController] status -> Promise<Permissions.AlertAction> in
                if status == .bluetoothOff {
                    guard let viewController = viewController else { return .value(.skip) }
                    return Permissions.instance.choiceAlert(for: .bluetooth, on: viewController)
                } else {
                    return .value(.skip)
                }
            }
             .then { action -> Promise<Void> in
                if action == .skip {
                    // Check status again because we don't want to ask user for turning on
                    // ENA if he tap Skip on Bluetooth turn ON
                    //
                    // We need to determine this here because we don't know if this is user action skip or auto skip
                    // in case that bluetooth was turned on
                    return manager.status()
                        .then { status -> Promise<Void> in
                            if status == .bluetoothOff {
                                return .value
                            } else {
                                return manager.serviceTurnOn()
                            }
                    }
                }
                else { throw InternalError.waitingForUser }
            }
        } else {
            return manager.serviceTurnOff()
        }
    }

    private func turnOnService() -> Promise<Void> {
        guard let manager = manager else {
            return .value
        }
        
        return  manager.status()
            .then { [viewController] status -> Promise<Permissions.AlertAction> in
                if status == .bluetoothOff {
                    guard let viewController = viewController else { return .value(.skip) }
                    return Permissions.instance.choiceAlert(for: .bluetooth, on: viewController)
                } else {
                    return .value(.skip)
                }
        }
        .then { action in
            return manager.serviceTurnOn()
        }
        .recover { [viewController] error -> Promise<Void> in
            if let error = error as? ENError {
                switch error.code {
                case .notAuthorized:
                    guard let viewController = viewController else { return .value }
                    return Permissions.instance.choiceAlert(for: .exposureNotification, on: viewController).asVoid()
                default:
                    console("")
                }
            }
            return .value
        }
    }
}
