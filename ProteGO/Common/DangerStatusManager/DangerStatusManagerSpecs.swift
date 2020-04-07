import Foundation
import Quick
import Nimble
import Valet
@testable import ProteGO

//swiftlint:disable force_unwrapping
class DangerStatusManagerSpecs: QuickSpec {
    override func spec() {
        describe("DangerStatusManager") {
            var sut: DangerStatusManager!
            var keychainMock: KeychainProviderType!
            var gcpClientMock: GcpClientMock!

            beforeEach {
                keychainMock = KeychainProviderMock()
                keychainMock.removeAllObjects()
                gcpClientMock = GcpClientMock()

                sut = DangerStatusManager(gcpClient: gcpClientMock, keychainProvider: keychainMock)
            }

            context("clear valet") {
                it("should return yellow status") {
                    expect(sut.currentStatus.value).to(equal(.yellow))
                }
            }

            context("valet with previously saved red status") {
                beforeEach {
                    keychainMock.set(string: DangerStatus.red.rawValue, forKey: Constants.KeychainKeys.currentDangerStatus)
                    sut = DangerStatusManager(gcpClient: gcpClientMock, keychainProvider: keychainMock)
                }

                it("should return red status") {
                    expect(sut.currentStatus.value).to(equal(.red))
                }
            }

            context("when downloaded green status from the web") {
                beforeEach {
                    gcpClientMock.getStatusResult = .success(GetStatusResponse(status: .green, beaconIds: []))
                    sut.updateCurrentDangerStatus()
                }

                it("should return green status") {
                    expect(sut.currentStatus.value).to(equal(.green))
                }

                it("save green to the valet") {
                    let rawValue = keychainMock.string(forKey: Constants.KeychainKeys.currentDangerStatus)
                    expect(rawValue).toNot(beNil())

                    let value = DangerStatus(rawValue: rawValue!)
                    expect(value).to(equal(DangerStatus.green))
                }
            }
        }
    }
}
