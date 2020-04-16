//
//  NotificationManager.swift
//  safesafe
//
//  Created by Marek Nowak on 15/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

protocol NotificationManagerProtocol {
    var userInfo: [AnyHashable : Any]? { get }

    func configure()
    func update(token: Data)
    func subscribe(topic: NotificationManager.Topic)
}

final class NotificationManager: NSObject {

    enum Topic: String {
        #warning("TODO: add topics here")
        case general
    }

    var userInfo: [AnyHashable : Any]?

    private func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    private func clearBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = .zero
    }
}

extension NotificationManager: NotificationManagerProtocol {
    func configure() {
        FirebaseApp.configure()

        registerForRemoteNotifications()
    }

    func update(token: Data) {
        Messaging.messaging().apnsToken = token
    }

    func subscribe(topic: NotificationManager.Topic) {
        Messaging.messaging().subscribe(toTopic: topic.rawValue)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        //push notification won't show on foreground
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        userInfo = response.notification.request.content.userInfo
        clearBadgeNumber()

        completionHandler()
    }
}
