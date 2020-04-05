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
            var testValet: Valet!
            var gcpClientMock: GcpClientMock!

            beforeEach {
                testValet = Valet.valet(with: Identifier(nonEmpty: "SecretsGeneratorSpecs")!, accessibility: .always)
                testValet.removeAllObjects()
                gcpClientMock = GcpClientMock()

                sut = DangerStatusManager(gcpClient: gcpClientMock, valet: testValet)
            }

            context("clear valet") {
                it("should return yellow status") {
                    expect(sut.currentStatus.value).to(equal(.yellow))
                }
            }

            context("valet with previously saved red status") {
                beforeEach {
                    testValet.set(string: DangerStatus.red.rawValue, forKey: Constants.KeychainKeys.currentDangerStatus)
                    sut = DangerStatusManager(gcpClient: gcpClientMock, valet: testValet)
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
                    let rawValue = testValet.string(forKey: Constants.KeychainKeys.currentDangerStatus)
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
