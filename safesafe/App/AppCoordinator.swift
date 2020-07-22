//
//  AppCoordinator.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit
import Siren

#if !LIVE
import DBDebugToolkit
#endif

final class AppCoordinator: CoordinatorType {
    
    private let dependencyContainer: DependencyContainer
    private let appManager = AppManager.instance
    private let window: UIWindow
    private let clearData = ClearData()
    private var noInternetAlert: UIAlertController?
    private var jailbreakAlert: UIAlertController?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    required init() {
        Fatal.execute("Not implemented")
    }
    
    init?(appWindow: UIWindow?, dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        RealmLocalStorage.setupEncryption()
        
        guard let window = appWindow else {
            Fatal.execute("Window doesn't exists")
        }
        
        self.window = window
    }
    
    func start() {
        setupScreenRecording()
        setupDebugToolkit()
        clearData.clear()
        
        let rootViewController = makeRootViewController()
        window.backgroundColor = .white
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        updateReminder()
        
        if #available(iOS 13.5, *) {
            configureJSBridge(with: rootViewController)
        }
        
        if #available(iOS 13.5, *) {
            // Don't register bg task on iPad devices that are not supported by EN
            guard UIDevice.current.model == "iPhone" else { return }
            dependencyContainer.backgroundTaskService.scheduleExposureTask()
        }
    }
    
    private func updateReminder() {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .annoying)
        siren.presentationManager = PresentationManager(
            alertMessage: "Dostępna jest nowsza wersja aplikacji. Zaktualizuj aplikację ProteGO Safe aby korzystać z pełni funkcjonalności.",
            forceLanguageLocalization: .polish
        )
        siren.wail()
    }
    
    private func makeRootViewController() -> UIViewController {
        let factory: PWAViewControllerFactory = dependencyContainer
        let viewController = factory.makePWAViewController()
        
        viewController.onAppear = { [weak self] in
            if self?.dependencyContainer.jailbreakService.isJailbroken == true {
                self?.showJailbreakAlert()
            }
        }
        
        return NavigationController(rootViewController: viewController)
    }
    
    private func setupDebugToolkit() {
        #if !LIVE && !STAGE
        DBDebugToolkit.setup()
        #endif
    }
    
    private func setupScreenRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenCaptureDidChange), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    private func showJailbreakAlert() {
        let alert = UIAlertController(
            title: nil,
            message: """
            Korzystasz z niezweryfikowanego urządzenia - bezpieczeństwo przesyłanych danych może być niższe. \
            Upewnij się, że używasz najnowszej, oficjalnej wersji systemu operacyjnego i w bezpieczny sposób łączysz się z Internetem. \
            Unikaj publicznie dostępnych sieci i korzystaj z własnej transmisji danych jeśli masz taką możliwość. \
            Nieautoryzowane konfiguracje ustawień telefonu mogą wpłynąć na wynik działania aplikacji oraz na bezpieczeństwo Twoich danych.
            """,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Rozumiem", style: .default))
        self.jailbreakAlert = alert
        
        window.rootViewController?.present(alert, animated: true)
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
    
    @objc
    private func screenCaptureDidChange(notification: Notification) {
        let isMirrored = UIScreen.screens.first(where: { $0.mirrored == UIScreen.main }).map ({ _ in true }) ?? false
        guard !isMirrored else  { return }
        
        if #available(iOS 13.0, *) {
            UIScreen.main.isCaptured ? HiderController.shared.show(windowScene: window.windowScene) : HiderController.shared.hide()
        } else {
            UIScreen.main.isCaptured ? HiderController.shared.show() : HiderController.shared.hide()
        }
        
    }
}
