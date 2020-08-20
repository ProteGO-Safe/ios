//
//  UploadValidationAlertManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 20/08/2020.
//

import UIKit

final class UploadValidationAlertManager: AlertManager {
    var viewController: UIViewController?
    
    func show(type: AlertType, result: @escaping (AlertAction) -> ()) {
        guard let viewController = presentingViewController() else {
            return
        }
        
        let (title, message) = content(type: type)
        guard !title.isEmpty && !message.isEmpty else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: AlertAction.ok.title, style: .cancel) { _  in
            result(.ok)
        }
        
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true)
    }
    
    private func content(type: AlertType) -> (title: String, message: String) {
        switch type {
        case .keysAtLeast:
            return (title: "UPLOAD_VALIDATION_ALERT_TITLE".localized(), message: "UPLOAD_VALIDATION_KEYS_AT_LEAST_MESSAGE".localized())
        case .keysMax:
            return (title: "UPLOAD_VALIDATION_ALERT_TITLE".localized(), message: "UPLOAD_VALIDATION_KEYS_MAX_LEAST_MESSAGE".localized())
        case .keysPerDayMax:
            return (title: "UPLOAD_VALIDATION_ALERT_TITLE".localized(), message: "UPLOAD_VALIDATION_KEYS_PER_DAY_MAX_LEAST_MESSAGE".localized())
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
