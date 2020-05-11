//
//  AppCoordinator.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit
import Network

#if !LIVE
import DBDebugToolkit
#endif

final class AppCoordinator: CoordinatorType {
    
    private let appManager = AppManager.instance
    private let window: UIWindow
    private let monitor = NWPathMonitor()
    private var noInternetAlert: UIAlertController?

    required init() {
        fatalError("Not implemented")
    }
    
    init?(appWindow: UIWindow?) {
        guard let window = appWindow else {
            fatalError("Window doesn't exists")
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        self.window = window
    }
    
    func start() {
        window.backgroundColor = .white
        window.rootViewController = pwa()
        window.makeKeyAndVisible()
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.noInternetAlert?.dismiss(animated: false)
                } else {
                    self?.showInternetAlert()
                }
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    private func pwa() -> UIViewController {
        let viewModel = PWAViewModel()
        let navigationController = NavigationController(rootViewController: PWAViewController(viewModel: viewModel))
        return navigationController
    }
    
    private func showInternetAlert() {
        noInternetAlert?.dismiss(animated: false)
        
        let noInternetAlert = UIAlertController(title: "Brak połączenia", message: "Brak połączenia z internetem", preferredStyle: .alert)
        window.rootViewController?.present(noInternetAlert, animated: true)
        
        self.noInternetAlert = noInternetAlert
    }
}
