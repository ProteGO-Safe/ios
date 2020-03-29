import Foundation
@testable import Anna

final class SecretsGeneratorMock: SecretsGeneratorType {
    var mockRealmEncryptionKey = Data()

    func getRealmEncryptionKey() throws -> Data {
        return mockRealmEncryptionKey
    }
}
