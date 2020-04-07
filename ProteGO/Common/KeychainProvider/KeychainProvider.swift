import Foundation
import Valet

final class KeychainProvider: KeychainProviderType {

    private let valet: Valet

    init(identifier: Identifier, accessibility: Accessibility) {
        self.valet = Valet.valet(with: identifier, accessibility: accessibility)
    }

    func string(forKey key: String) -> String? {
        return self.valet.string(forKey: key)
    }

    func object(forKey key: String) -> Data? {
        return self.valet.object(forKey: key)
    }

    @discardableResult
    func set(string: String, forKey key: String) -> Bool {
        return self.valet.set(string: string, forKey: key)
    }

    @discardableResult
    func set(object: Data, forKey key: String) -> Bool {
        return self.valet.set(object: object, forKey: key)
    }

    @discardableResult
    func removeObject(forKey key: String) -> Bool {
        return self.valet.removeObject(forKey: key)
    }

    @discardableResult
    func removeAllObjects() -> Bool {
        return self.valet.removeAllObjects()
    }
}
