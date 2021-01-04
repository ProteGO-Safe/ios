//
//  AppDelegate.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import CoreData
import UIKit
import PromiseKit
import Firebase

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var appCoordinator: AppCoordinator?
    let dependencyContainer = DependencyContainer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        NetworkMonitoring.shared.start() // initialize network monitoring observation
        
        if #available(iOS 13.5, *) {
            dependencyContainer.backgroundTaskService.registerExposureTask()
        }
 
        if #available(iOS 13.0, *) {} else {
            window = UIWindow(frame: UIScreen.main.bounds)
            appCoordinator = AppCoordinator(appWindow: window, dependencyContainer: dependencyContainer)
            appCoordinator?.start()
        }
        
        StoredDefaults.standard.set(value: true, key: .isFirstRun)
        
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL { //Deeplink
            DeepLinkingWorker.shared.navigate(with: url)
        } else if let activityDictionary = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] { //Universal link
            for key in activityDictionary.keys {
                if let userActivity = activityDictionary[key] as? NSUserActivity {
                    if let url = userActivity.webpageURL {
                        DeepLinkingWorker.shared.navigate(with: url)
                    }
                }
            }
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        NotificationManager.shared.update(token: deviceToken)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationManager.shared.clearBadgeNumber()
        NotificationManager.shared.registerAPNSIfNeeded()
        NotificationManager.shared.registerNotificationCategories()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        HiderController.shared.show()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        HiderController.shared.hide()
    }
    
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let url = userActivity.webpageURL else {  return false }
        DeepLinkingWorker.shared.navigate(with: url)
        
        return true
    }
}

@inlinable public func console(_ value: Any?, type: Logger.LogType = .regular, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.log(value, type: type, file: file, function: function, line: line)
}
