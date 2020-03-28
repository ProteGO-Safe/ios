import Foundation

protocol SecretsGeneratorType {
    func getRealmEncryptionKey() throws -> Data
}
