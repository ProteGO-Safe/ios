import Foundation
import Quick
import Nimble
import Valet
@testable import ProteGO

class DangerStatusManagerSpecs: QuickSpec {
    override func spec() {
        describe("DangerStatusManager") {
            var sut: DangerStatusManager!
            var keychainMock: KeychainProviderType!

            beforeEach {
                keychainMock = KeychainProviderMock()
                keychainMock.removeAllObjects()

                sut = DangerStatusManager(keychainProvider: keychainMock)
            }

            context("clear valet") {
                it("should return yellow status") {
                    expect(sut.currentStatus.value).to(equal(.yellow))
                }
            }

            context("valet with previously saved red status") {
                beforeEach {
                    keychainMock.set(string: DangerStatus.red.rawValue, forKey: Constants.KeychainKeys.currentDangerStatus)
                    sut = DangerStatusManager(keychainProvider: keychainMock)
                }

                it("should return red status") {
                    expect(sut.currentStatus.value).to(equal(.red))
                }
            }

            context("when updated with green status") {
                beforeEach {
                    sut.update(with: .green)
                }

                it("should return green status") {
                    expect(sut.currentStatus.value).to(equal(.green))
                }

                it("save green to the keychain") {
                    let rawValue = keychainMock.string(forKey: Constants.KeychainKeys.currentDangerStatus)
                    expect(rawValue).toNot(beNil())

                    if let rawValue = rawValue {
                        let value = DangerStatus(rawValue: rawValue)
                        expect(value).to(equal(DangerStatus.green))
                    }
                }
            }
        }
    }
}
