import Foundation
import Valet
import Quick
import Nimble
@testable import ProteGO

//swiftlint:disable force_try
class SecretsGeneratorSpecs: QuickSpec {
    override func spec() {
        describe("SecretsGenerator") {
            var sut: SecretsGenerator!
            var keychainMock: KeychainProviderType!

            beforeEach {
                keychainMock = KeychainProviderMock()
                keychainMock.removeAllObjects()
                sut = SecretsGenerator(keychainProvider: keychainMock)
            }

            context("realm encyption key") {
                var value: Data!

                beforeEach {
                    keychainMock.removeAllObjects()
                }

                context("after initializing") {
                    beforeEach {
                        value = try! sut.getRealmEncryptionKey()
                    }

                    it("should not be nil") {
                        expect(value).toNot(beNil())
                    }

                    it("should have proper length") {
                        expect(value.count).to(equal(Constants.Realm.encryptionKeyLength))
                    }
                }

                context("when invoked twice") {
                    var value2: Data!
                    beforeEach {
                        value = try! sut.getRealmEncryptionKey()
                        value2 = try! sut.getRealmEncryptionKey()
                    }

                    it("should return the same value ") {
                        expect(value).to(equal(value2))
                    }
                }

                context("after keychain reset") {
                    var value2: Data!
                    beforeEach {
                        value = try! sut.getRealmEncryptionKey()
                        keychainMock.removeAllObjects()
                        value2 = try! sut.getRealmEncryptionKey()
                    }

                    it("should reutrn different values") {
                        expect(value).toNot(equal(value2))
                    }
                }
            }
        }

    }
}
