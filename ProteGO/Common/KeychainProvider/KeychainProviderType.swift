import Foundation

protocol KeychainProviderType: class {
    func string(forKey key: String) -> String?

    func object(forKey key: String) -> Data?

    @discardableResult
    func set(string: String, forKey key: String) -> Bool

    @discardableResult
    func set(object: Data, forKey key: String) -> Bool

    @discardableResult
    func removeObject(forKey key: String) -> Bool

    @discardableResult
    func removeAllObjects() -> Bool
}
