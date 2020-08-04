//
//  NetworkingAlertManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 30/06/2020.
//

import UIKit

final class NetworkingAlertManager: AlertManager {
    private(set) var viewController: UIViewController?
    
    func show(type: AlertType, result: @escaping (AlertAction) -> Void) {
        guard let viewController = presentingViewController() else {
            return
        }
        let (title, message) = content(type: type)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: AlertAction.cancel.title, style: .cancel) { _  in
            result(.cancel)
        }
        
        let retryAction = UIAlertAction(title: AlertAction.retry.title, style: .default) { _ in
            result(.retry)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        viewController.present(alert, animated: true)
    }
    
    private func content(type: AlertType) -> (title: String, message: String) {
        switch type {
        case .noInternet:
            return (title: "INTERNET_CONNECTION_ALERT_TITLE".localized(), message: "INTERNET_CONNECTION_ALERT_MESSAGE".localized())
        case .uploadGeneral:
            return (title: "COMMON_ERROR_ALERT_TITLE".localized(), message: "UNKNOWN_ERROR_ALERT_MESSAGE".localized())
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
