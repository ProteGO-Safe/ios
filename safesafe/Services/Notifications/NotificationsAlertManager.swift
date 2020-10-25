//
//  NotificationsAlertManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 12/10/2020.
//

import UIKit

final class NotificationsAlertManager: AlertManager {
    var viewController: UIViewController?
    
    func show(type: AlertType, result: @escaping (AlertAction) -> ()) {
        guard let viewController = presentingViewController() else {
            return
        }
        let (title, message) = content(type: type)
        guard !title.isEmpty && !message.isEmpty else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: AlertAction.cancel.title, style: .cancel) { _  in
            result(.cancel)
        }
        
        let setttingsAction = UIAlertAction(title: AlertAction.settings.title, style: .default) { _ in
            result(.settings)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(setttingsAction)
        
        viewController.present(alert, animated: true)
    }
    
    private func content(type: AlertType) -> (title: String, message: String) {
        switch type {
        case .pushNotificationSettings:
            return (title: "NOTIFICATIONS_ALERT_TITLE".localized(), message: "NOTIFICATIONS_ALERT_MESSAGE".localized())
        default:
            return (title: "", message: "")
        }
    }
    
    private func presentingViewController() -> UIViewController? {
        if let viewController = viewController {
            return viewController
        }
        
        guard let keyWindow = UIWindow.key, let rootViewController = keyWindow.rootViewController else {
            return nil
        }
        
        return rootViewController
    }
}
