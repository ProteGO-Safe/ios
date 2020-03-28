import Foundation
import RealmSwift
import RxSwift
import Valet

final class RealmManager: RealmManagerType {

    var realm: Realm {
        do {
            let config = Realm.Configuration(
                fileURL: realmFilePath,
                encryptionKey: try self.secretsGenerator.getRealmEncryptionKey(),
                schemaVersion: Constants.Realm.modelVersion,
                migrationBlock: { _, _ in}
            )

            return try Realm(configuration: config)
        } catch {
            fatalError("Can't create Realm database. Error: \(error)")
        }
    }

    private let realmFilePath: URL

    private let secretsGenerator: SecretsGeneratorType

    init(realmFilePath: URL, secretsGenerator: SecretsGeneratorType) {
        self.realmFilePath = realmFilePath
        self.secretsGenerator = secretsGenerator
    }
}
