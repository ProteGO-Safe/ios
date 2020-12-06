//
//  AppCoordinator.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit
import Siren

final class AppCoordinator: CoordinatorType {
    
    private let dependencyContainer: DependencyContainer
    private let appManager = AppManager.instance
    private let window: UIWindow
    private let clearData = ClearData()
    private var noInternetAlert: UIAlertController?
    private var jailbreakAlert: UIAlertController?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    required init() {
        Fatal.execute("Not implemented")
    }
    
    init?(appWindow: UIWindow?, dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer

        guard let window = appWindow else {
            Fatal.execute("Window doesn't exists")
        }
        
        self.window = window
        setupAppLifecycleNotifications()
    }
    
    func start() {
        moveDafaultsToAppGroup()
        
        #if !STAGE_SCREENCAST
        setupScreenRecording()
        #endif
    
        clearData.clear()
        
        let rootViewController = makeRootViewController()
        window.backgroundColor = .white
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        updateReminder()
        configureJSBridge(with: rootViewController)
        
        
        if #available(iOS 13.5, *) {
            // Don't register bg task on iPad devices that are not supported by EN
            guard UIDevice.current.model == "iPhone" else { return }
            dependencyContainer.backgroundTaskService.scheduleExposureTask()
        }
    }
    
    private func setupAppLifecycleNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func moveDafaultsToAppGroup() {
        StoredDefaults.standard.set(value: LanguageController.Constants.defaultLanguage, key: .defaultLanguage, useAppGroup: true)
        StoredDefaults.standard.set(value: LanguageController.selected, key: .selectedLanguage, useAppGroup: true)
    }
    
    private func updateReminder() {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .annoying)
        siren.presentationManager = PresentationManager(
            alertMessage: "SIREN_ALERT_MESSAGE".localized(),
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
    
    private func setupScreenRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenCaptureDidChange), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    private func showJailbreakAlert() {
        let alert = UIAlertController(
            title: nil,
            message: "JAILBREAK_MESSAGE".localized(),
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "JAILBREAK_ALERT_BUTTON_TITLE".localized(), style: .default))
        self.jailbreakAlert = alert
        
        window.rootViewController?.present(alert, animated: true)
    }
    
    private func showInternetAlert() {
        noInternetAlert?.dismiss(animated: false)
        
        let noInternetAlert = UIAlertController(title: "INTERNET_CONNECTION_ALERT".localized(), message: "INTERNET_CONNECTION_MESSAGE".localized(), preferredStyle: .alert)
        window.rootViewController?.present(noInternetAlert, animated: true)
        
        self.noInternetAlert = noInternetAlert
    }
    
    private func configureJSBridge(with viewController: UIViewController) {
        if #available(iOS 13.5, *) {
            let factory: ExposureNotificationJSBridgeFactory = dependencyContainer
            dependencyContainer.jsBridge.registerExposureNotification(
                with: factory.makeExposureNotificationJSBridge(with: viewController),
                diagnosisKeysUploadService: dependencyContainer.diagnosisKeysUploadService
            )
        }
        
        dependencyContainer.jsBridge.register(districtService: dependencyContainer.districtsService)
        dependencyContainer.jsBridge.register(freeTestService: dependencyContainer.freeTestService)
    }
    
    @objc private func applicationWillEnterForeground(notification: Notification) {
        let storedData = dependencyContainer.notificationPayloadParser.getStoredNotifications()
        dependencyContainer.notificationHistoryWorker.parseSharedContainerNotifications(
            data: storedData,
            keys: NotificationUserInfoParser.Key.self
        )
        .done { success in
            console("Did finish parsing shared notifications, success: \(success)")
            if success {
                self.dependencyContainer.notificationPayloadParser.clearStoredNotifications()
            }
        }
        .catch { console($0, type: .error) }
    }
    
    @objc private func screenCaptureDidChange(notification: Notification) {
        let isMirrored = UIScreen.screens.first(where: { $0.mirrored == UIScreen.main }).map ({ _ in true }) ?? false
        guard !isMirrored else  { return }
        
        if #available(iOS 13.0, *) {
            UIScreen.main.isCaptured ? HiderController.shared.show(windowScene: window.windowScene) : HiderController.shared.hide()
        } else {
            UIScreen.main.isCaptured ? HiderController.shared.show() : HiderController.shared.hide()
        }
        
    }
}
