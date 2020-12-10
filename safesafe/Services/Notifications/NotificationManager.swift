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
    func registerAPNSIfNeeded()
    func registerForNotifications(remote: Bool) -> Guarantee<Bool>
    func currentStatus() -> Guarantee<UNAuthorizationStatus>
    func clearBadgeNumber()
    func update(token: Data)
    func unsubscribeFromDailyTopic(timestamp: TimeInterval)
    func showDistrictStatusLocalNotification(with changed: [DistrictStorageModel], observed: [ObservedDistrictStorageModel], timestamp: Int, delay: TimeInterval)
}

extension NotificationManagerProtocol {
    func registerForNotifications(remote: Bool = true) -> Guarantee<Bool> {
        return registerForNotifications(remote: remote)
    }
}

final class NotificationManager: NSObject {
    
    enum Constants {
        static let dailyTopicDateFormat = "ddMMyyyy"
        static let districtNotificationIdentifier = "DistrictNotificationID"
    }
    
    static let shared = NotificationManager()
    
    private let notificationsWorker = NotificationHistoryWorker(storage: RealmLocalStorage())
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
        static let generalLocalizedPrefix = "general-localized"
        static let daysNum = 50
        
        case general
        case generalLocalized
        case daily(startDate: Date)
        
        var toString: [String] {
            switch self {
            case .general:
                #if LIVE
                return [Topic.generalPrefix]
                #else
                return ["\(Topic.generalPrefix)\(Topic.devSuffix)"]
                #endif
            case .generalLocalized:
                #if LIVE
                return [Topic.generalLocalized]
                #else
                return ["\(Topic.generalLocalized)\(Topic.devSuffix)"]
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
                #if LIVE
                topics.append("\(Topic.dailyPrefix)\(formatted)")
                #else
                topics.append("\(Topic.dailyPrefix)\(formatted)\(Topic.devSuffix)")
                #endif
            }
            
            return topics
        }
    }
        
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
    
    func registerForNotifications(remote: Bool = true) -> Guarantee<Bool> {
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
                
                if remote {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                    StoredDefaults.standard.set(value: true, key: .didAuthorizeAPN)
                }
                
                fulfill(true)
            }
        }
    }

    func showDistrictStatusLocalNotification(with changed: [DistrictStorageModel], observed: [ObservedDistrictStorageModel], timestamp: Int, delay: TimeInterval) {
        let lastTimestamp: Int = StoredDefaults.standard.get(key: .districtStatusNotificationTimestamp) ?? .zero
        guard lastTimestamp < timestamp else { return }
        
        let observedIds = observed.map { $0.districtId }
        let changedObserved: [DistrictStorageModel] = changed.filter { observedIds.contains($0.id) }
        
        var body = ""
        if observed.isEmpty {
            console("📪 prepare local notification: Observed districts empty")
            body = "DISTRICT_STATUS_CHANGE_NOTIFICATION_MESSAGE_OBSERVE_DISABLED".localized()
        } else {
            if changedObserved.isEmpty {
                console("📪 prepare local notification: No changes in observed")
                body = "DISTRICT_STATUS_CHANGE_NOTIFICATION_MESSAGE_NO_OBSERVED".localized()
            } else if changedObserved.count == 1 {
                console("📪 prepare local notification: 1 change in observed")
                body = "DISTRICT_STATUS_CHANGE_NOTIFICATION_MESSAGE_OBSERVED_SINGLE".localized()
                body.append(" \(ditrictsList(changedObserved))")
            } else {
                console("📪 prepare local notification: Multi change in observed")
                body = String(format: "DISTRICT_STATUS_CHANGE_NOTIFICATION_MESSAGE_OBSERVED_MULTI".localized(), changedObserved.count)
                body.append(" \(ditrictsList(changedObserved))")
            }
        }
        
        guard !body.isEmpty else { return }
        showLocalNotification(title: "DISTRICT_STATUS_CHANGE_NOTIFICATION_TITLE".localized(), body: body, delay: delay)
        
        StoredDefaults.standard.set(value: timestamp, key: .districtStatusNotificationTimestamp)
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
        
        #if LIVE
        let topic = "\(Topic.dailyPrefix)\(formatted)"
        #else
        let topic = "\(Topic.dailyPrefix)\(formatted)\(Topic.devSuffix)"
        #endif
        
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                console(error, type: .error)
            }
        }
    }
    
    func registerAPNSIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                guard StoredDefaults.standard.get(key: .didAuthorizeAPN) == nil else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                StoredDefaults.standard.set(value: true, key: .didAuthorizeAPN)
            default: ()
            }
        }
    }
    
    private func showLocalNotification(title: String?, body: String, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        if let title = title {
            content.title = title
        }
        content.body = body
    
        let messageID = UUID().uuidString
        let userInfo: [String: Any] = [NotificationUserInfoParser.Key.uuid.rawValue: messageID]
        content.userInfo = userInfo
        
        notificationsWorker.appendLocalNotification(title: content.title, content: content.body, messageID: messageID)
            .done{ success in console("Add local notification to historical data with success: \(success)")}
            .catch { console($0, type: .error) }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: Constants.districtNotificationIdentifier, content: content, trigger: trigger)
        
        console("🚀 schedule notification with delay: \(delay)")
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                console("😡 Local notification error \(error)", type: .error)
            }
        }
    }
    
    private func ditrictsList(_ changedObservedDistricts: [DistrictStorageModel]) -> String {
        var data: [String] = []
        
        for district in changedObservedDistricts {
            let districtName = "\(String(format: "DISTRICT_NAME_PREFIXED".localized(), district.name)) - \(district.localizedZoneName)"
            data.append(districtName)
        }
        
        return data.joined(separator: "; ")
    }
    
    
    private func subscribeTopics() {
        Messaging.messaging().unsubscribe(fromTopic: Topic.general.toString[0])
        Messaging.messaging().subscribe(toTopic: Topic.generalLocalized.toString[0])
        
        let didSubscribedFCMTopics: Bool = StoredDefaults.standard.get(key: .didSubscribeFCMTopics) ?? false
        guard !didSubscribedFCMTopics else {
            return
        }
        
        var allTopics: [String] = []
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
    
    private func parseSharedNotifications() {
        let notificationPayloadParser = NotificationUserInfoParser()
        let storedData = notificationPayloadParser.getStoredNotifications()
        let notificationHistoryWorker = NotificationHistoryWorker(storage: RealmLocalStorage())
        notificationHistoryWorker.parseSharedContainerNotifications(
            data: storedData,
            keys: NotificationUserInfoParser.Key.self
        )
        .done { success in
            console("Did finish parsing shared notifications, success: \(success)")
            if success {
                notificationPayloadParser.clearStoredNotifications()
            }
        }
        .catch { console($0, type: .error) }
    }
    
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        parseSharedNotifications()
        
        completionHandler([.alert])
    }
    
    // Here we are when user taped notification
    //
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        let userInfo = response.notification.request.content.userInfo
        guard let messageUUID = userInfo[NotificationUserInfoParser.Key.uuid.rawValue] as? String else { return }
        
        if response.notification.request.identifier == Constants.districtNotificationIdentifier {
            DeepLinkingWorker.shared.navigate(to: .currentRestrictions, messageId: messageUUID)
        } else {
            let parser = NotificationUserInfoParser()
            
            let info: [String: RouteModel.Value] = [NotificationUserInfoParser.Key.uuid.rawValue: .string(messageUUID)]
            if let routeModel: RouteModel = parser.routeData(userInfo: userInfo, appendInfo: info),
               let jsonString = routeModel.asJSONString() {
                
                DeepLinkingWorker.shared.navigate(jsonString)
            } else {
                // navigate to history view
                DeepLinkingWorker.shared.navigate(to: .notificationsHistory, messageId: messageUUID)
            }
            
            
        }
        
        completionHandler()
    }
}

extension StoredDefaults.Key {
    static let didSubscribeFCMTopics = StoredDefaults.Key("didSubscribeFCMTopics")
    static let didAuthorizeAPN = StoredDefaults.Key("didAuthorizeAPN")
    static let districtStatusNotificationTimestamp = StoredDefaults.Key("districtStatusNotificationTimestamp")
}
