import Foundation
import Valet

final class SecretsGenerator: SecretsGeneratorType {
    func getRealmEncryptionKey() throws -> Data {
        if let key = self.keychainProvider.object(forKey: Constants.KeychainKeys.realmEncryptionKey) {
            return key
        }

        var bytes = [Int8](repeating: 0, count: Constants.Realm.encryptionKeyLength)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        if result != errSecSuccess {
            logger.error("Problem with generating random bytes")
            throw SecretsGeneratorError.GenerateSecureKeyError
        }

        let key = Data(bytes: bytes, count: Constants.Realm.encryptionKeyLength)
        self.keychainProvider.set(object: key, forKey: Constants.KeychainKeys.realmEncryptionKey)
        return key
    }

    private let keychainProvider: KeychainProviderType

    init(keychainProvider: KeychainProviderType) {
        self.keychainProvider = keychainProvider
    }
}

enum SecretsGeneratorError: ProteGOError {
    case GenerateSecureKeyError
}
