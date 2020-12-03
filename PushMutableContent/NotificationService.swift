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
        let localizedList = parser.parseLocalized(userInfo: request.content.userInfo)
        
        guard
            let selectedLanguageISO: String = StoredDefaults.standard.get(key: .selectedLanguage, useAppGroup: true),
            let selectedModel = localizedList.first(where: { $0.laguageISO.lowercased() == selectedLanguageISO.lowercased() }),
            let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        else {
            return
        }
           
        bestAttemptContent.title = selectedModel.title
        bestAttemptContent.body = selectedModel.content
        
        contentHandler(bestAttemptContent)
        
    }
    
    override func serviceExtensionTimeWillExpire() {
    }

}
