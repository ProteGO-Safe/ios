//
//  AppDelegate.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    private let notificationManager = NotificationManager.shared

    private var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        notificationManager.configure()

        if #available(iOS 13.0, *) {} else {
            window = UIWindow(frame: UIScreen.main.bounds)
            appCoordinator = AppCoordinator(appWindow: window)
            appCoordinator?.start()
        }
        
        StoredDefaults.standard.set(value: true, key: .isFirstRun)
        
        BluetraceManager.shared.turnOn()
        EncounterMessageManager.shared.setup()
        
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
        print(token)
        notificationManager.update(token: deviceToken)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        notificationManager.clearBadgeNumber()
    }
    
    // MARK: - Core Data

    /**
     Property from https://github.com/opentrace-community/opentrace-ios/blob/master/OpenTrace/AppDelegate.swift
     
     Used in OpenTrace sources.
    */
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "tracer")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
}

@inlinable public func console(_ value: Any?, type: Logger.LogType = .regular, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.log(value, type: type, file: file, function: function, line: line)
}
