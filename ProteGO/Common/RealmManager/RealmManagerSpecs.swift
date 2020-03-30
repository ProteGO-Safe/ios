import Foundation
import Quick
import Nimble
@testable import ProteGO

//swiftlint:disable force_try
class RealmManagerSpecs: QuickSpec {
    override func spec() {
        describe("RealmManager") {
            var sut: RealmManager!
            var secretsGeneratorMock: SecretsGeneratorMock!

            beforeEach {
                secretsGeneratorMock = SecretsGeneratorMock()
                secretsGeneratorMock.mockRealmEncryptionKey = Data(repeating: 6, count: Constants.Realm.encryptionKeyLength)
                let realmDatabaseBaseURL = URL(fileURLWithPath: "realmManagerSpecs.realm",
                                               relativeTo: FileManager.default.temporaryDirectory)
                let realmURLs = [
                    realmDatabaseBaseURL,
                    realmDatabaseBaseURL.appendingPathExtension("lock"),
                    realmDatabaseBaseURL.appendingPathExtension("note"),
                    realmDatabaseBaseURL.appendingPathExtension("management")
                ]
                for URL in realmURLs {
                    try? FileManager.default.removeItem(at: URL)
                }

                sut = RealmManager(realmFilePath: realmDatabaseBaseURL, secretsGenerator: secretsGeneratorMock)
            }

            context("encryption key") {
                var value: Data!

                beforeEach {
                    value = sut.realm.configuration.encryptionKey
                }

                it("should be correct") {
                    expect(value).to(equal(try! secretsGeneratorMock.getRealmEncryptionKey()))
                }
            }
        }
    }
}
