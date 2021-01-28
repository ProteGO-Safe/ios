//
//  NotificationService.swift
//  PushMutableContent
//
//  Created by Łukasz Szyszkowski on 19/11/2020.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        let parser = NotificationUserInfoParser()
        
        if let covidStatsDictionary = parser.parseCovidStats(userInfo: request.content.userInfo)?.dictionary {
            parser.addSharedData(data: covidStatsDictionary, for: .sharedCovidStats)
        }
        
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else { return }
        
        guard
            let selectedLanguageISO: String = StoredDefaults.standard.get(key: .selectedLanguage, useAppGroup: true),
            let selectedModel = parser.selectedLanguageData(lang: selectedLanguageISO, userInfo: request.content.userInfo)
        else {
            // Save default content if translations doesn't exist
            //
            let routeRaw: String? = parser.routeData(userInfo: request.content.userInfo)
            let dictionary = parser.parseNotification(title: bestAttemptContent.title, content: bestAttemptContent.body, route: routeRaw)
            parser.addSharedData(data: dictionary, for: .sharedNotifications)
            contentHandler(bestAttemptContent)
            return
        }
        
        let routeRaw: String? = parser.routeData(userInfo: request.content.userInfo)
        let dictionary = parser.parseNotification(title: selectedModel.title, content: selectedModel.content, route: routeRaw)
        parser.addSharedData(data: dictionary, for: .sharedNotifications)
        
        var modifiedUserInfo = request.content.userInfo
        modifiedUserInfo[NotificationUserInfoParser.Key.uuid.rawValue] = dictionary[NotificationUserInfoParser.Key.id.rawValue] as? String
        bestAttemptContent.userInfo = modifiedUserInfo
        bestAttemptContent.title = selectedModel.title
        bestAttemptContent.body = selectedModel.content
        
        contentHandler(bestAttemptContent)
        
    }
    
    override func serviceExtensionTimeWillExpire() {
    }

}
