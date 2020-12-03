//
//  NotificationDataresponse.swift
//  PushMutableContent
//
//  Created by Łukasz Szyszkowski on 02/12/2020.
//

import Foundation

struct NotificationDataResponse: Codable {
    
    let title: String
    let content: String
    let localizedNotifications: [LocalizedNotificationModel]
}
