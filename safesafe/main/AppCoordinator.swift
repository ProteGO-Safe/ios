//
//  AppCoordinator.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit
import Network

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
                    self?.startBluetraceIfNeeded()
                } else {
                    self?.showInternetAlert()
                }
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    private func pwa() -> UIViewController {
        let viewModel = PWAViewModel()
        let navigationController = NavigationControler(rootViewController: PWAViewController(viewModel: viewModel))
        return navigationController
    }
    
    private func startBluetraceIfNeeded() {
        guard appManager.isBluetraceAllowed else { return }
        
        BluetraceManager.shared.turnOn()
        EncounterMessageManager.shared.authSetup()
    }
    
    private func showInternetAlert() {
        noInternetAlert?.dismiss(animated: false)
        
        let noInternetAlert = UIAlertController(title: "Brak połączenia", message: "Brak połączenia z internetem", preferredStyle: .alert)
        window.rootViewController?.present(noInternetAlert, animated: true)
        
        self.noInternetAlert = noInternetAlert
    }
}
