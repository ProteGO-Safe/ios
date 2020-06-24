//
//  LocalStorage.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 24/05/2020.
//

import Foundation
import RealmSwift

protocol LocalStorable: Object {}

protocol LocalStorageProtocol {
    func append<T: LocalStorable>(_ object: T, completion: ((Result<Void, Error>) -> ())?)
    func append<T: LocalStorable>(_ objects: [T], completion: ((Result<Void, Error>) -> ())?)
    func fetch<T: LocalStorable>() -> Array<T>
    func remove<T: LocalStorable>(_ object: T, completion: ((Result<Void, Error>) -> ())?)
    func remove<T: LocalStorable>(_ objects: [T], completion: ((Result<Void, Error>) -> ())?)
    static func clearAll()
}

extension LocalStorageProtocol {
    static func setupEncryption() {}
    
    func append<T: LocalStorable>(_ objects: [T], completion: ((Result<Void, Error>) -> ())? = nil) {
        append(objects, completion: completion)
    }
    
    func append<T: LocalStorable>(_ object: T, completion: ((Result<Void, Error>) -> ())? = nil) {
        append(object, completion: completion)
    }
}

final class RealmLocalStorage: LocalStorageProtocol {
    
    private let realm: Realm
    
    required init?(_ realm: Realm? = nil) {
        do {
            self.realm = try realm ?? Realm(configuration: RealmLocalStorage.defaultConfiguration())
        } catch {
            return nil
        }
    }
    
    func append<T: LocalStorable>(_ object: T, completion: ((Result<Void, Error>) -> ())? = nil) {
        guard let object = object as? Object else {
            completion?(.failure(InternalError.invalidDataType))
            return
        }
        
        do {
            try realm.write {
                realm.add(object)
            }
            completion?(.success)
        } catch {
            completion?(.failure(error))
        }
    }
    
    func append<T: LocalStorable>(_ objects: [T], completion: ((Result<Void, Error>) -> ())? = nil) {
        guard let objects = objects as? [Object] else {
            completion?(.failure(InternalError.invalidDataType))
            return
        }
        
        do {
            try realm.write {
                realm.add(objects)
            }
            completion?(.success)
        } catch {
            completion?(.failure(error))
        }
    }
    
    func fetch<T: LocalStorable>() -> Array<T> {
        guard let type = T.self as? Object.Type else {
            fatalError()
        }
        return realm.objects(type).compactMap { $0 as? T }
    }
    
    func remove<T: LocalStorable>(_ object: T, completion: ((Result<Void, Error>) -> ())? = nil) {
        do {
            try realm.write {
                realm.delete(object)
            }
            completion?(.success)
        } catch {
            completion?(.failure(error))
        }
    }
    
    func remove<T: LocalStorable>(_ objects: [T], completion: ((Result<Void, Error>) -> ())? = nil) {
        do {
            try realm.write {
                realm.delete(objects)
            }
            completion?(.success)
        } catch {
            completion?(.failure(error))
        }
    }
    
    static func clearAll() {
        do {
            let realm = try Realm(configuration: defaultConfiguration())
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            console(error, type: .error)
        }
    }
}

extension RealmLocalStorage {
    static func setupEncryption() {
        guard KeychainService.shared.getData(for: .realmEncryption) == nil else { return }
        
        var keyData = Data(count: 64)
        _ = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 62, $0.baseAddress!)
        }
        
        KeychainService.shared.set(data: keyData, for: .realmEncryption)
    }
    
    static func defaultConfiguration() throws -> Realm.Configuration {
        guard let encryptionKey = KeychainService.shared.getData(for: .realmEncryption) else {
            throw InternalError.keychainKeyNotExists
        }
        return Realm.Configuration(encryptionKey: encryptionKey)
    }
}

extension KeychainService.Key {
    static let realmEncryption = KeychainService.Key("realmEncryption")
}
