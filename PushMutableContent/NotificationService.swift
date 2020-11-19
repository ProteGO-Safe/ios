//
//  NotificationService.swift
//  PushMutableContent
//
//  Created by Łukasz Szyszkowski on 19/11/2020.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let defaultLang: String = StoredDefaults.standard.get(key: .defaultLanguage, useAppGroup: true) ?? "Can't read"
        let selectedLanguage: String = StoredDefaults.standard.get(key: .selectedLanguage, useAppGroup: true) ?? "Can't read"
        
        let dataTitle = ((request.content.userInfo as? [String: Any])?["title"] as? String) ?? "can't read title"
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            bestAttemptContent.body = "\(dataTitle) default lang: \(defaultLang), selected lang: \(selectedLanguage)"
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
