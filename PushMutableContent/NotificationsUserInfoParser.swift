//
//  NotificationsUserInfoParser.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 03/12/2020.
//

import Foundation

final class NotificationUserInfoParser {
    
    private enum Key: String {
        case title
        case content
        case languageISO
    }
    
    func parseLocalized(userInfo: [AnyHashable: Any]?) -> [LocalizedNotificationModel] {
        var localizedList: [LocalizedNotificationModel] = []
        guard
            let userInfoJSON = userInfo as? [String: Any],
            let localizedNotificationsRaw = userInfoJSON["localizedNotifications"] as? String,
            let localizedNotificationsData = localizedNotificationsRaw.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: localizedNotificationsData, options: .allowFragments),
            let objects = json as? [[String: Any]]
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
}
