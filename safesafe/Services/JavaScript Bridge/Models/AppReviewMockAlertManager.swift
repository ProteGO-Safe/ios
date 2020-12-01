//
//  AppReviewMockAlertManager.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 23/11/2020.
//

import UIKit

final class AppReviewMockAlertManager: AlertManager {
    private(set) var viewController: UIViewController?
    
    func show(type: AlertType, result: @escaping (AlertAction) -> Void) {
        guard let viewController = presentingViewController() else {
            return
        }
        let (title, message) = content(type: type)
        guard !title.isEmpty && !message.isEmpty else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: AlertAction.cancel.title, style: .cancel) { _  in
            result(.ok)
        }
        
        let moreAction = UIAlertAction(title: AlertAction.more.title, style: .default) { _ in
            UIApplication.shared.open(
                URL(string: "https://developer.apple.com/documentation/storekit/skstorereviewcontroller/2851536-requestreview")!,
                options: [:],
                completionHandler: nil)
        }
        
        alert.addAction(okAction)
        alert.addAction(moreAction)
        
        viewController.present(alert, animated: true)
    }
    
    private func content(type: AlertType) -> (title: String, message: String) {
        switch type {
        case .appReviewMock:
            return (title: "App Review".localized(), message: "This is an app review mock alert. While it's running from testflight or ad-hoc there is no possibility to show real system App Review Alert.".localized())
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
