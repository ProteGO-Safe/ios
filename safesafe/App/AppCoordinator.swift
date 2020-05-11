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
    private let pogoMM: PogoMotionManager
    
    deinit {
        removeUIApplicationObservers()
    }
    
    required init() {
        fatalError("Not implemented")
    }
    
    init?(appWindow: UIWindow?) {
        guard let window = appWindow else {
            fatalError("Window doesn't exists")
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        pogoMM = PogoMotionManager(window: window)
        self.window = window
    }
    
    func start() {
        setupDebugToolkit()
        
        window.backgroundColor = .white
        window.rootViewController = pwa()
        window.makeKeyAndVisible()
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.noInternetAlert?.dismiss(animated: false)
                    self?.startBluetraceIfNeeded()
                    self?.signInIfNeeded()
                } else {
                    self?.showInternetAlert()
                }
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
        addUIApplicationObservers()
    }
    
    private func pwa() -> UIViewController {
        let viewModel = PWAViewModel()
        let navigationController = NavigationController(rootViewController: PWAViewController(viewModel: viewModel))
        return navigationController
    }
    
    private func startBluetraceIfNeeded() {
        guard appManager.isBluetraceAllowed else { return }
        
        BluetraceManager.shared.turnOn()
        EncounterMessageManager.shared.authSetup()
    }
    
    private func signInIfNeeded() {
        LoginManager().signIn { result in
            if case let .failure(error) = result {
                console(error, type: .error)
            }
        }
    }
    
    private func showInternetAlert() {
        noInternetAlert?.dismiss(animated: false)
        
        let noInternetAlert = UIAlertController(title: "Brak połączenia", message: "Brak połączenia z internetem", preferredStyle: .alert)
        window.rootViewController?.present(noInternetAlert, animated: true)
        
        self.noInternetAlert = noInternetAlert
    }
    
    private func addUIApplicationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    private func removeUIApplicationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupDebugToolkit() {
        #if !LIVE        
        DBDebugToolkit.setup()
        DBDebugToolkit.add(DBCustomActionFactory.makeBluetraceDBDumpAction(window: window))
        #endif
    }
    
    @objc
    private func applicationDidBecomeActive(notification: Notification) {
        pogoMM.startAccelerometerUpdates()
    }
    
    @objc
    private func appicationDidEnterBackground(notification: Notification) {
        pogoMM.stopAllMotion()
    }
    
    @objc
    private func applicationWillEnterForeground(notification: Notification) {
        BluetraceUtils.removeData21DaysOld()
        pogoMM.stopAllMotion()
    }
    
    @objc
    private func applicationWillTerminate(notification: Notification) {
        pogoMM.stopAllMotion()
    }
}
