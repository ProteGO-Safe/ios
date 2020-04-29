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
import FirebaseMessaging
import PromiseKit

protocol NotificationManagerProtocol {
    func registerForRemoteNotifications() -> Guarantee<Bool>
    func currentStatus() -> Guarantee<UNAuthorizationStatus>
    func configure()
    func clearBadgeNumber()
    func update(token: Data)
    func unsubscribeFromDailyTopic(timestamp: TimeInterval)
    func stringifyUserInfo() -> String?
    func clearUserInfo()
}

final class NotificationManager: NSObject {
    
    enum Constants {
        static let dailyTopicDateFormat = "ddMMyyyy"
    }
    
    static let shared = NotificationManager()
    
    private let dispatchGroupQueue = DispatchQueue(label: "disptach.protegosafe.group")
    private let dipspatchQueue = DispatchQueue(label: "dispatch.protegosafe.main")
    private let group = DispatchGroup()
    
    var didAuthorizeAPN: Bool {
        return StoredDefaults.standard.get(key: .didAuthorizeAPN) ?? false
    }
    
    enum Topic {
        static let devSuffix = "-dev"
        static let dailyPrefix = "daily_"
        static let generalPrefix = "general"
        static let daysNum = 50
        
        case general
        case daily(startDate: Date)
        
        var toString: [String] {
            switch self {
            case .general:
                #if DEV
                return ["\(Topic.generalPrefix)\(Topic.devSuffix)"]
                #elseif STAGE
                return ["\(Topic.generalPrefix)\(Topic.devSuffix)"]
                #elseif LIVE
                return [Topic.generalPrefix]
                #endif
            case let .daily(startDate):
                return dailyTopics(startDate: startDate)
            }
        }
        
        private func dailyTopics(startDate: Date) -> [String] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = NotificationManager.Constants.dailyTopicDateFormat
            
            let calendar = Calendar.current
            var topics: [String] = []
            for dayNum in (0..<Topic.daysNum) {
                guard let date = calendar.date(byAdding: .day, value: dayNum, to: startDate) else {
                    continue
                }
                let formatted = dateFormatter.string(from: date)
                #if DEV
                topics.append("\(Topic.dailyPrefix)\(formatted)\(Topic.devSuffix)")
                #elseif LIVE
                topics.append("\(Topic.dailyPrefix)\(formatted)")
                #endif
            }
            
            return topics
        }
    }
    
    private var userInfo: [AnyHashable : Any]?
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

extension NotificationManager: NotificationManagerProtocol {
    func currentStatus() -> Guarantee<UNAuthorizationStatus> {
        return Guarantee { fulfill in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                fulfill(settings.authorizationStatus)
            }
        }
    }
    
    func registerForRemoteNotifications() -> Guarantee<Bool> {
        return Guarantee { fulfill in
            let didRegister = StoredDefaults.standard.get(key: .didAuthorizeAPN) ?? false
            guard !didRegister else {
                fulfill(true)
                return
            }
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                guard granted else {
                    fulfill(false)
                    return
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                StoredDefaults.standard.set(value: true, key: .didAuthorizeAPN)
                fulfill(true)
            }
        }
    }
    
    func configure() {
        FirebaseApp.configure()
    }
    
    func update(token: Data) {
        Messaging.messaging().apnsToken = token
        subscribeTopics()
    }
    
    func clearBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = .zero
    }
    
    func unsubscribeFromDailyTopic(timestamp: TimeInterval) {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NotificationManager.Constants.dailyTopicDateFormat
        
        let formatted = dateFormatter.string(from: date)
        
        #if DEV
        let topic = "\(Topic.dailyPrefix)\(formatted)\(Topic.devSuffix)"
        #elseif STAGE
        let topic = "\(Topic.dailyPrefix)\(formatted)\(Topic.devSuffix)"
        #elseif LIVE
        let topic = "\(Topic.dailyPrefix)\(formatted)"
        #endif
        
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                console(error, type: .error)
            }
        }
    }
    
    func clearUserInfo() {
        userInfo = nil
    }
    
    func stringifyUserInfo() -> String? {
        guard let userInfo = userInfo else {
            return nil
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else {
            return nil
        }
        
        return String(data: jsonData, encoding: .utf8)
    }
    
    private func subscribeTopics() {
        let didSubscribedFCMTopics: Bool = StoredDefaults.standard.get(key: .didSubscribeFCMTopics) ?? false
        guard !didSubscribedFCMTopics else {
            return
        }
        
        var allTopics: [String] = []
        allTopics.append(contentsOf: Topic.general.toString)
        allTopics.append(contentsOf: Topic.daily(startDate: Date()).toString)
        
        dipspatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            for topic in allTopics {
                self.group.enter()
                self.dispatchGroupQueue.async {
                    Messaging.messaging().subscribe(toTopic: topic) { error in
                        if let error = error {
                            console(error, type: .error)
                        }
                        self.group.leave()
                    }
                }
                self.group.wait()
            }
            
            DispatchQueue.main.async {
                StoredDefaults.standard.set(value: true, key: .didSubscribeFCMTopics)
            }
        }
        
    }
    
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        userInfo = notification.request.content.userInfo

        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        userInfo = response.notification.request.content.userInfo
        completionHandler()
    }
}

extension StoredDefaults.Key {
    static let didSubscribeFCMTopics = StoredDefaults.Key("didSubscribeFCMTopics")
    static let didAuthorizeAPN = StoredDefaults.Key("didAuthorizeAPN")
}
