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
        
        guard
            let selectedLanguageISO: String = StoredDefaults.standard.get(key: .selectedLanguage, useAppGroup: true),
            let selectedModel = parser.selectedLanguageData(lang: selectedLanguageISO, userInfo: request.content.userInfo),
            let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        else {
            return
        }
        
        let routeRaw: String? = parser.routeData(userInfo: request.content.userInfo)
        let dictionary = parser.parseNotification(title: selectedModel.title, content: selectedModel.content, route: routeRaw)
        parser.addStoredNotification(data: dictionary)
        
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
