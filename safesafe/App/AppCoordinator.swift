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
import DeviceCheck
import ExposureNotification

#if !LIVE
import DBDebugToolkit
#endif

final class AppCoordinator: CoordinatorType {
    
    private let appManager = AppManager.instance
    private let window: UIWindow
    private let monitor = NWPathMonitor()
    private let clearData = ClearData()
    private var noInternetAlert: UIAlertController?
    
    @available(iOS 13.5, *)
    private lazy var exposureService: ExposureServiceProtocol = self.setupExposureNotificationService()

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
        setupDebugToolkit()
        FirebaseApp.configure()
        clearData.clear()
        
        let rootViewController = pwa()
        window.backgroundColor = .white
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        if #available(iOS 13.5, *) {
            JSBridge.shared.register(exposureNotificationManager: ExposureNotificationJSBridge(manager: exposureService, viewController: rootViewController))
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
    
    private func pwa() -> UIViewController {
        let viewModel = PWAViewModel()
        let navigationController = NavigationController(rootViewController: PWAViewController(viewModel: viewModel))
        return navigationController
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
    private func setupExposureNotificationService() -> ExposureServiceProtocol {
        let manager = ENManager()
        let remoteConfiguration = RemoteConfiguration()
        let diagnosisKeysDownloadService = DiagnosisKeysDownloadService(with: remoteConfiguration)
        let configurationService = RemoteConfiguration()
        
        return ExposureService(
            exposureManager: manager,
            diagnosisKeysService: diagnosisKeysDownloadService,
            configurationService: configurationService
        )
    }
}
