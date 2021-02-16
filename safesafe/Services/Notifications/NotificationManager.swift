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
    func parseSharedCovidStats()
    func parseSharedNotifications()
    func subscribeForCovidStatsTopicByDefault()
    func manageUserCovidStatsTopic(subscribe: Bool, completion: @escaping ((Bool) -> ()))
    func registerNotificationCategories()
    func register(dependencyContainer: DependencyContainer)
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
        
        enum NotificationCategory {
            static let declineCovidStatsNotificationActionId = "declineCovidStatsNotificationActionId"
            static let covidStatsCategoryId = "covidStatsCategoryId"
        }
    }

    static let shared = NotificationManager()
    
    private var notificationsWorker: NotificationHistoryWorkerType?
    private var dashboardWorker: DashboardWorkerType?
    private let dispatchGroupQueue = DispatchQueue(label: "disptach.protegosafe.group")
    private let dipspatchQueue = DispatchQueue(label: "dispatch.protegosafe.main")
    private let group = DispatchGroup()
    
    var didAuthorizeAPN: Bool {
        return StoredDefaults.standard.get(key: .didAuthorizeAPN) ?? false
    }
    
    enum Topic {
        static let devSuffix = "-dev"
        static let stageSuffix = "-stage"
        static let dailyPrefix = "daily-localized_"
        static let generalPrefix = "general"
        static let generalLocalizedPrefix = "general-localized"
        static let covidStatsPrefix = "covid-stats-ios"
        static let daysNum = 50
        
        case general
        case generalLocalized
        case covidStats
        case daily(startDate: Date)
        
        var toString: [String] {
            switch self {
            case .general:
                #if LIVE
                return [Topic.generalPrefix]
                #else
                return [
                    "\(Topic.generalPrefix)\(Topic.devSuffix)",
                    "\(Topic.generalPrefix)\(Topic.stageSuffix)"
                ]
                #endif
            case .generalLocalized:
                #if LIVE
                return [Topic.generalLocalizedPrefix]
                #else
                return [
                    "\(Topic.generalLocalizedPrefix)\(Topic.devSuffix)",
                    "\(Topic.generalLocalizedPrefix)\(Topic.stageSuffix)"
                ]
                #endif
            case .covidStats:
                #if LIVE
                return [Topic.covidStatsPrefix]
                #else
                return [
                    "\(Topic.covidStatsPrefix)\(Topic.devSuffix)",
                    "\(Topic.covidStatsPrefix)\(Topic.stageSuffix)"
                ]
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
                topics.append("\(Topic.dailyPrefix)\(formatted)\(Topic.stageSuffix)")
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
    func register(dependencyContainer: DependencyContainer) {
        self.notificationsWorker = dependencyContainer.notificationHistoryWorker
        self.dashboardWorker = dependencyContainer.dashboardWorker
    }
    
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
        subscribeForCovidStatsTopicByDefault()
        subscribeTopics()
    }
    
    func clearBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = .zero
    }
    
    func subscribeForCovidStatsTopicByDefault() {
        let didSubscribeForCovidStatsTopic = StoredDefaults.standard.get(key: .didSubscribeForCovidStatsTopicByDefault) ?? false
        if !didSubscribeForCovidStatsTopic {
            for topic in Topic.covidStats.toString {
                Messaging.messaging().subscribe(toTopic: topic) { error in
                    if let error = error {
                        console(error, type: .error)
                    } else {
                        StoredDefaults.standard.set(value: true, key: .didSubscribeForCovidStatsTopicByDefault)
                        StoredDefaults.standard.set(value: true, key: .didUserSubscribeForCovidStatsTopic)
                    }
                }
            }
        }
    }
    
    func manageUserCovidStatsTopic(subscribe: Bool, completion: @escaping ((Bool) -> ())) {
        if subscribe {
            for topic in Topic.covidStats.toString {
                Messaging.messaging().subscribe(toTopic: topic) { error in
                    if let error = error {
                        console(error, type: .error)
                        completion(false)
                    } else {
                        StoredDefaults.standard.set(value: true, key: .didUserSubscribeForCovidStatsTopic)
                        completion(true)
                    }
                }
            }
        } else {
            for topic in Topic.covidStats.toString {
                Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                    if let error = error {
                        console(error, type: .error)
                        completion(false)
                    } else {
                        StoredDefaults.standard.set(value: false, key: .didUserSubscribeForCovidStatsTopic)
                        completion(true)
                    }
                }
            }
        }
    }
    
    func unsubscribeFromDailyTopic(timestamp: TimeInterval) {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NotificationManager.Constants.dailyTopicDateFormat
        
        let formatted = dateFormatter.string(from: date)
        
        #if LIVE
        let topics = ["\(Topic.dailyPrefix)\(formatted)"]
        #else
        let topics = [
            "\(Topic.dailyPrefix)\(formatted)\(Topic.devSuffix)",
            "\(Topic.dailyPrefix)\(formatted)\(Topic.stageSuffix)"
        ]
        #endif

        for topic in topics {
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if let error = error {
                    console(error, type: .error)
                }
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
        
        notificationsWorker?.appendLocalNotification(title: content.title, content: content.body, messageID: messageID)
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
    
    func registerNotificationCategories() {
        let didRegisterCovidStats: Bool = StoredDefaults.standard.get(key: .didRegisterCovidStatsNotificationCategory) ?? false
        
        if !didRegisterCovidStats {
            let declineCovidStatsNotifications = UNNotificationAction(
                identifier: Constants.NotificationCategory.declineCovidStatsNotificationActionId,
                title: "DECLINE_COVID_STATS_NOTIFICATIONS_BUTTON_TITLE".localized(),
                options: UNNotificationActionOptions(rawValue: 0))
            
            let covidStatsCategory =
                UNNotificationCategory(
                    identifier: Constants.NotificationCategory.covidStatsCategoryId,
                    actions: [declineCovidStatsNotifications],
                    intentIdentifiers: [],
                    hiddenPreviewsBodyPlaceholder: "",
                    options: .customDismissAction)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.setNotificationCategories([covidStatsCategory])
            
            StoredDefaults.standard.set(value: true, key: .didRegisterCovidStatsNotificationCategory)
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
        Topic.general.toString.forEach(Messaging.messaging().unsubscribe(fromTopic:))
        Topic.generalLocalized.toString.forEach(Messaging.messaging().subscribe(toTopic:))
        
        let didSubscribedFCMTopics: Bool = StoredDefaults.standard.get(key: .didSubscribeLocalizedFCMTopics) ?? false

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
                StoredDefaults.standard.set(value: true, key: .didSubscribeLocalizedFCMTopics)
            }
        }
        
    }
    
    func parseSharedNotifications() {
        let notificationPayloadParser = NotificationUserInfoParser()
        let storedData = notificationPayloadParser.getSharedData(for: .sharedNotifications)
        let notificationHistoryWorker = NotificationHistoryWorker(storage: RealmLocalStorage())
        notificationHistoryWorker.parseSharedContainerNotifications(
            data: storedData,
            keys: NotificationUserInfoParser.Key.self
        )
        .done { success in
            console("Did finish parsing shared notifications, success: \(success)")
            if success {
                notificationPayloadParser.clearSharedData(for: .sharedNotifications)
            }
        }
        .catch { console($0, type: .error) }
    }
    
    func parseSharedCovidStats() {
        let notificationPayloadParser = NotificationUserInfoParser()
        let storedData = notificationPayloadParser.getSharedData(for: .sharedCovidStats)
        dashboardWorker?.parseSharedContainerCovidStats(objects: storedData)
            .done {
                notificationPayloadParser.clearSharedData(for: .sharedCovidStats)
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
        parseSharedCovidStats()
        
        completionHandler([.alert])
    }
    
    // Here we are when user taped notification
    //
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case Constants.NotificationCategory.declineCovidStatsNotificationActionId:
            manageUserCovidStatsTopic(subscribe: false) { _ in }
        default: ()
        }
        
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
    static let didSubscribeLocalizedFCMTopics = StoredDefaults.Key("didSubscribeLocalizedFCMTopics")
    static let didAuthorizeAPN = StoredDefaults.Key("didAuthorizeAPN")
    static let districtStatusNotificationTimestamp = StoredDefaults.Key("districtStatusNotificationTimestamp")
    static let didRegisterCovidStatsNotificationCategory = StoredDefaults.Key("didRegisterCovidStatsNotificationCategory")
    static let didSubscribeForCovidStatsTopicByDefault = StoredDefaults.Key("didSubscribeCovidStatsTopicByDefault")
    static let didUserSubscribeForCovidStatsTopic = StoredDefaults.Key("didUserSubscribeForCovidStatsTopic")
}
