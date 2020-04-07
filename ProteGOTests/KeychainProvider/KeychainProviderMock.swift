import Foundation
@testable import ProteGO

final class KeychainProviderMock: KeychainProviderType {

    private var database: [String: AnyObject] = [:]

    func string(forKey key: String) -> String? {
        return self.database[key] as? String
    }

    func object(forKey key: String) -> Data? {
        return self.database[key] as? Data
    }

    func set(string: String, forKey key: String) -> Bool {
        self.database[key] = string as AnyObject
        return true
    }

    func set(object: Data, forKey key: String) -> Bool {
        self.database[key] = object as AnyObject
        return true
    }

    func removeObject(forKey key: String) -> Bool {
        (self.database.removeValue(forKey: key) != nil)
    }

    func removeAllObjects() -> Bool {
        self.database = [:]
        return true
    }
}
