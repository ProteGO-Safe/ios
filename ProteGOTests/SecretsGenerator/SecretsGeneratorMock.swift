import Foundation
@testable import ProteGO

final class SecretsGeneratorMock: SecretsGeneratorType {
    var mockRealmEncryptionKey = Data()

    func getRealmEncryptionKey() throws -> Data {
        return mockRealmEncryptionKey
    }
}
