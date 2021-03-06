//
//  SceneDelegate.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var appCoordinator: AppCoordinator?

    var window: UIWindow?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            window = window ?? UIWindow(windowScene: windowScene)
            appCoordinator = AppCoordinator(appWindow: window, dependencyContainer: appDelegate.dependencyContainer)
            appCoordinator?.start()
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        guard
            let userActivity = connectionOptions.userActivities.first,
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
        else {
            return
        }
        
        DeepLinkingWorker.shared.navigate(with: incomingURL)
    }
    
    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationManager.shared.clearBadgeNumber()
        NotificationManager.shared.registerAPNSIfNeeded()
        NotificationManager.shared.registerNotificationCategories()
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        HiderController.shared.hide()
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        HiderController.shared.show(windowScene: window?.windowScene)
    }

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {  return }
        DeepLinkingWorker.shared.navigate(with: url)
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        
    }
}

