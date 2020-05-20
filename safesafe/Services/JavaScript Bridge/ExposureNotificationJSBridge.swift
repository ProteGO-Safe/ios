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
    
    private weak var manager: ExposureServiceProtocol?
    private weak var viewController: UIViewController?

    init(manager: ExposureServiceProtocol, viewController: UIViewController) {
        self.manager = manager
        self.viewController = viewController
    }
    
    func enableService(enable: Bool?) -> Promise<Void> {
        guard let manager = manager, let enable = enable else {
            return .value
        }
        return (enable ? turnOnService() : manager.setExposureNotificationEnabled(false))
            .recover { error -> Guarantee<()> in
                guard let error = error as? ENError else {
                    return .value
                }
                
                switch error.code {
                case .notEnabled:
                    console("ENA not enabled", type: .warning)
                case .restricted:
                    console("ENA retrictedf", type: .warning)
                case .invalidated:
                    console("ENA invalidated", type: .warning)
                case .notAuthorized:
                    console("ENA Not authorized")
                default:
                    console("ENA Error code")
                }
                
                return .value
        }
    }
    
    private func turnOnService() -> Promise<Void> {
        guard let manager = manager else {  return .value }
        return  manager.setExposureNotificationEnabled(true)
            .recover { [viewController] error -> Promise<Void> in
                if let error = error as? ENError {
                    switch error.code {
                    case .notAuthorized:
                        guard let viewController = viewController else { return .value }
                        return Permissions.instance.choiceAlert(for: .exposureNotification, on: viewController)
                            .then { action -> Promise<Void> in
                                guard action == .skip else {  return .init(error: PMKError.cancelled) }
                                return .value
                        }
                    default:
                        return .value
                    }
                } else {
                    return .value
                }
        }
    }
}

