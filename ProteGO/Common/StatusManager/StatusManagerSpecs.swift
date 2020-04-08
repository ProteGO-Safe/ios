import Foundation
import Quick
import Nimble
@testable import ProteGO

//swiftlint:disable function_body_length
class StatusManagerSpecs: QuickSpec {
    override func spec() {
        describe("StatusManager") {
            var sut: StatusManager!
            var gcpClientMock: GcpClientMock!
            var registrationManagerMock: RegistrationManagerMock!
            var beaconIdsManagerMock: BeaconIdsManagerMock!
            var dangerStatusManagerMock: DangerStatusManagerMock!

            beforeEach {
                gcpClientMock = GcpClientMock()
                registrationManagerMock = RegistrationManagerMock()
                beaconIdsManagerMock = BeaconIdsManagerMock()
                dangerStatusManagerMock = DangerStatusManagerMock()

                sut = StatusManager(gcpClient: gcpClientMock,
                                    registrationManager: registrationManagerMock,
                                    beaconIdsManager: beaconIdsManagerMock,
                                    dangerStatusManager: dangerStatusManagerMock)
            }

            context("when manually forced update") {
                let mockStatus = DangerStatus.green
                let mockBeaconIds = [GetStatusResponseBeaconId(beaconId: BeaconId.random(), date: Date()),
                                     GetStatusResponseBeaconId(beaconId: BeaconId.random(), date: Date())]
                beforeEach {
                    gcpClientMock.getStatusResult = .success(GetStatusResponse(status: mockStatus,
                                                                               beaconIds: mockBeaconIds))
                    sut.updateCurrentDangerStatusAndBeaconIds()
                }

                it("should call danger manager") {
                    dangerStatusManagerMock.verifyCall(
                        withIdentifier: "update",
                        arguments: [mockStatus],
                        mode: .times(1))
                }

                it("should call beacon ids manager") {
                    beaconIdsManagerMock.verifyCall(
                        withIdentifier: "update",
                        arguments: [mockBeaconIds],
                        mode: .times(1))
                }
            }

            context("when registration has finished") {
                beforeEach {
                    registrationManagerMock.isUserRegisteredSubject.onNext(true)
                }

                it("should trigger GCP endpoint") {
                    gcpClientMock.verifyCall(
                    withIdentifier: "getStatus",
                    arguments: [NSNull()],
                    mode: .times(1))
                }
            }
        }
    }
}
