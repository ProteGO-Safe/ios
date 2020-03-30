import Foundation
import Valet
import Quick
import Nimble
@testable import ProteGO

//swiftlint:disable force_unwrapping force_try
class SecretsGeneratorSpecs: QuickSpec {
    override func spec() {
        describe("SecretsGenerator") {
            var sut: SecretsGenerator!
            var testValet: Valet!

            beforeEach {
                testValet = Valet.valet(with: Identifier(nonEmpty: "SecretsGeneratorSpecs")!, accessibility: .always)
                testValet.removeAllObjects()
                sut = SecretsGenerator(valet: testValet)
            }

            context("realm encyption key") {
                var value: Data!

                beforeEach {
                    testValet.removeAllObjects()
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
                        testValet.removeAllObjects()
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
