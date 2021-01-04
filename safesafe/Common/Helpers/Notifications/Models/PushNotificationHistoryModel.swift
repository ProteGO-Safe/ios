//
//  PushNotificationHistoryModel.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 06/12/2020.
//

import Foundation
import RealmSwift

 final class PushNotificationHistoryModel: Object, LocalStorable {
    
    struct EncodableModel: Encodable {
        let id: String
        let timestamp: Int
        let title: String
        let content: String
    }
    
    @objc dynamic var id: String = .empty
    @objc dynamic var timestamp: Int = .zero
    @objc dynamic var title: String = .empty
    @objc dynamic var content: String = .empty
    @objc dynamic var route: String? = nil
    
    override class func primaryKey() -> String? { "id" }
    
    convenience init?(object: [String: Any], keys: NotificationUserInfoParser.Key.Type) {
        self.init()
        
        guard
            let id = object[keys.id.rawValue] as? String,
            let timestamp = object[keys.timestamp.rawValue] as? Int,
            let title = object[keys.title.rawValue] as? String,
            let content = object[keys.content.rawValue] as? String
        else {
            return nil
        }
        
        self.id = id
        self.timestamp = timestamp
        self.title = title
        self.content = content
        self.route = object[keys.route.rawValue] as? String
    }
    
    func asEncodable() -> EncodableModel {
        .init(id: id, timestamp: timestamp, title: title, content: content)
    }
}
