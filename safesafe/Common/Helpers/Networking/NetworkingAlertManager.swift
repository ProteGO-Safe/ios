//
//  NetworkingAlertManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 30/06/2020.
//

import UIKit

final class NetworkingAlertManager: AlertManager {
    private(set) var viewController: UIViewController?
    
    func show(type: AlertType, result: @escaping (AlertAction) -> ()) {
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
            return (title: "Błąd", message: "Brak połączenia z internetem.")
        case .uploadGeneral:
            return (title: "Błąd", message: "Wystąpił nieoczekiwany błąd.")
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
