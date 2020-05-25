//
//  AppCoordinator.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Firebase
import UIKit
import Network

#if !LIVE
import DBDebugToolkit
#endif

final class AppCoordinator: CoordinatorType {
    
    private let dependencyContainer = DependencyContainer()
    private let appManager = AppManager.instance
    private let window: UIWindow
    private let monitor = NWPathMonitor()
    private let clearData = ClearData()
    private var noInternetAlert: UIAlertController?

    required init() {
        fatalError("Not implemented")
    }
    
    init?(appWindow: UIWindow?) {
        RealmLocalStorage.setupEncryption()
        
        guard let window = appWindow else {
            fatalError("Window doesn't exists")
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        self.window = window
    }
    
    func start() {
        setupDebugToolkit()
        FirebaseApp.configure()
        clearData.clear()
        
        let rootViewController = makeRootViewController()
        window.backgroundColor = .white
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        if #available(iOS 13.5, *) {
            configureJSBridge(with: rootViewController)
        }
        
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
    
    private func makeRootViewController() -> UIViewController {
        let factory: PWAViewControllerFactory = dependencyContainer
        return NavigationController(rootViewController: factory.makePWAViewController())
    }
    
    private func setupDebugToolkit() {
        #if !LIVE
        DBDebugToolkit.setup()
        #endif
    }
    
    private func showInternetAlert() {
        noInternetAlert?.dismiss(animated: false)
        
        let noInternetAlert = UIAlertController(title: "Brak połączenia", message: "Brak połączenia z internetem", preferredStyle: .alert)
        window.rootViewController?.present(noInternetAlert, animated: true)
        
        self.noInternetAlert = noInternetAlert
    }
    
    @available(iOS 13.5, *)
    private func configureJSBridge(with viewController: UIViewController) {
        let factory: ExposureNotificationJSBridgeFactory = dependencyContainer
        
        dependencyContainer.jsBridge.registerExposureNotification(
            with: factory.makeExposureNotificationJSBridge(with: viewController),
            diagnosisKeysUploadService: dependencyContainer.diagnosisKeysUploadService
        )
    }
    
}
