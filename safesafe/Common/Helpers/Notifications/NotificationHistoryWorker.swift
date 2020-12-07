//
//  NotificationHistoryWorker.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 06/12/2020.
//

import Foundation
import PromiseKit

protocol NotificationHistoryWorkerType {
    func parseSharedContainerNotifications(data: [[String: Any]], keys: NotificationUserInfoParser.Key.Type) -> Promise<Bool>
    func appendLocalNotification(title: String, content: String) -> Promise<Bool>
    func fetchAllNotifications() -> Promise<[PushNotificationHistoryModel]>
    func clearHistory(with ids: [String]) -> Promise<Void>
}

final class NotificationHistoryWorker: NotificationHistoryWorkerType {
    
    private let storage: RealmLocalStorage?
    
    init(storage: RealmLocalStorage?) {
        self.storage = storage
    }
    
    func parseSharedContainerNotifications(data: [[String : Any]], keys: NotificationUserInfoParser.Key.Type) -> Promise<Bool> {
        guard let storage = storage else {
            return .init(error: InternalError.nilValue)
        }
        
        return Promise { seal in
            storage.beginWrite()
            for object in data {
                guard let model = PushNotificationHistoryModel(object: object, keys: keys) else { continue }
                
                storage.append(model, policy: .all, completion: nil)
            }
            
            do {
                try storage.commitWrite()
                seal.fulfill(true)
            } catch {
                console(error, type: .error)
                seal.fulfill(false)
            }
        }
    }
    
    func appendLocalNotification(title: String, content: String) -> Promise<Bool> {
        guard let storage = storage else {
            return .init(error: InternalError.nilValue)
        }
        
        return Promise { seal in
            storage.beginWrite()
            
            let model = PushNotificationHistoryModel()
            model.id = UUID().uuidString
            model.timestamp = Int(Date().timeIntervalSince1970)
            model.title = title
            model.content = content
            
            do {
                try storage.commitWrite()
                seal.fulfill(true)
            } catch {
                console(error, type: .error)
                seal.fulfill(false)
            }
        }
    }
    
    func fetchAllNotifications() -> Promise<[PushNotificationHistoryModel]> {
        guard let storage = storage else {
            return .init(error: InternalError.nilValue)
        }
        
        return Promise { seal in
            let all: [PushNotificationHistoryModel] = storage.fetch()
            seal.fulfill(all)
        }
    }
    
    func clearHistory(with ids: [String]) -> Promise<Void> {
        guard let storage = storage else {
            return .init(error: InternalError.nilValue)
        }
        
        return Promise { seal in
            let all: [PushNotificationHistoryModel] = storage.fetch().filter { ids.contains($0.id) }
            storage.remove(all, completion: nil)
            
            seal.fulfill(())
        }
    }
}
