//
//  NotificationsUserInfoParser.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 03/12/2020.
//

import Foundation

final class NotificationUserInfoParser {
    
    enum Key: String {
        case route
        case notification
        case localizedNotifications
        case title
        case content
        case languageISO
        case id
        case uuid
        case timestamp
        case covidStats
    }
    
    func parseLocalized(userInfo: [AnyHashable: Any]?) -> [LocalizedNotificationModel] {
        var localizedList: [LocalizedNotificationModel] = []
        guard
            let userInfoJSON = userInfo as? [String: Any],
            let localizedNotificationsRaw = userInfoJSON[Key.notification.rawValue] as? String,
            let localizedNotificationsData = localizedNotificationsRaw.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: localizedNotificationsData, options: .allowFragments),
            let objects = (json as? [String: Any])?[Key.localizedNotifications.rawValue] as? [[String: Any]]
        else {
            return localizedList
        }
        
        for object in objects {
            guard
                let title = object[Key.title.rawValue] as? String,
                let content = object[Key.content.rawValue] as? String,
                let languageISO = object[Key.languageISO.rawValue] as? String
            else {
                continue
            }
            
            localizedList.append(.init(title: title, content: content, laguageISO: languageISO))
        }
        
        return localizedList
    }
    
    func selectedLanguageData(lang: String, userInfo: [AnyHashable: Any]?) -> LocalizedNotificationModel? {
        parseLocalized(userInfo: userInfo).first(where: { $0.laguageISO.lowercased() == lang.lowercased() })
    }
    
    func routeData(userInfo: [AnyHashable: Any]?, appendInfo: [String: RouteModel.Value] = [:]) -> RouteModel? {
        let decoder = JSONDecoder()
        guard
            let routeRaw: String = routeData(userInfo: userInfo),
            let data = routeRaw.data(using: .utf8),
            var model = try? decoder.decode(RouteModel.self, from: data)
        else {
            return nil
        }
        
        var params = model.params
        
        for info in appendInfo {
            params[info.key] = info.value
        }
        
        model.params = params
        
        return model
    }
    
    func routeData(userInfo: [AnyHashable: Any]?) -> String? {
        guard
            let userInfoJSON = userInfo as? [String: Any],
            let routeRaw = userInfoJSON[Key.route.rawValue] as? String
        else {
            return nil
        }
        
        return routeRaw
    }
    
    func clearSharedData(for key: StoredDefaults.Key) {
        StoredDefaults.standard.delete(key: key, useAppGroup: true)
    }
    
    func getSharedData(for key: StoredDefaults.Key) -> [[String: Any]] {
        let data: Any? = StoredDefaults.standard.get(key: key, useAppGroup: true)
        if let data = data as? Data {
            return (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [[String: Any]]) ?? []
        }
        
        return []
    }
    
    func addSharedData(data: [String: Any], for key: StoredDefaults.Key) {
        var storedNotifications = getSharedData(for: key)
        storedNotifications.append(data)
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: storedNotifications, requiringSecureCoding: false) else {
            return
        }
        
        StoredDefaults.standard.set(value: data, key: key, useAppGroup: true)
    }
    
    func parseNotification(title: String, content: String, route: String?) -> [String: Any] {
        var dict: [String: Any] = [
            Key.id.rawValue: UUID().uuidString,
            Key.timestamp.rawValue: Int(Date().timeIntervalSince1970),
            Key.title.rawValue: title,
            Key.content.rawValue: content
        ]
        
        if let route = route {
            dict[Key.route.rawValue] = route
        }
        
        return dict
    }
    
    func covidStatsData(userInfo: [AnyHashable: Any]?) -> String? {
        guard
            let userInfoJSON = userInfo as? [String: Any],
            let covidStatsRaw = userInfoJSON[Key.covidStats.rawValue] as? String
        else {
            return nil
        }
        
        return covidStatsRaw
    }
    
    func parseCovidStats(userInfo: [AnyHashable: Any]) -> PushNotificationCovidStatsModel? {
        let decoder = JSONDecoder()
        guard
            let covidStatsRaw: String = covidStatsData(userInfo: userInfo),
            let data = covidStatsRaw.data(using: .utf8),
            let model = try? decoder.decode(PushNotificationCovidStatsModel.self, from: data)
        else {
            return nil
        }
        
        return model
    }
}

extension StoredDefaults.Key {
    static let sharedNotifications = StoredDefaults.Key("storedNotifications")
    static let sharedCovidStats = StoredDefaults.Key("sharedCovidStats")
}
