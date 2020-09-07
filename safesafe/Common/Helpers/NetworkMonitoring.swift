//
//  Network.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 17/06/2020.
//

import UIKit
import Network

final class NetworkMonitoring {
    static let shared = NetworkMonitoring()
    
    var isInternetAvailable: Bool {
        return networkPath.currentPath.status == .satisfied
    }
    private let networkPath: NWPathMonitor
    
    func start() {
         networkPath.start(queue: DispatchQueue.global(qos: .background))
    }
    
    func showInternetAlert(in viewController: UIViewController, action: @escaping (AlertAction) -> ()) {
        let alert = UIAlertController(title: "INTERNET_CONNECTION_ALERT_TITLE".localized(), message: "INTERNET_CONNECTION_ALERT_MESSAGE".localized(), preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "RETRY_BUTTON_TITLE".localized(), style: .default) { _ in
            action(.retry)
        }
        let cancelAction = UIAlertAction(title: "CANCEL_BUTTON_TITLE".localized(), style: .cancel) { _ in
            action(.cancel)
        }
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true)
    }
    
    private init() {
        self.networkPath = NWPathMonitor()
    }
}
