import Foundation
import Quick
import Nimble
@testable import ProteGO

class BeaconIdAgentSpecs: QuickSpec {
    override func spec() {
        describe("BeaconIdAgent") {
            var sut: BeaconIdAgent!
            var beaconIdsManagerMock: BeaconIdsManagerMock!
            var encountersManagerMock: EncountersManagerMock!
            var currentDateProviderMock: CurrentDateProviderMock!

            beforeEach {
                beaconIdsManagerMock = BeaconIdsManagerMock()
                encountersManagerMock = EncountersManagerMock()
                currentDateProviderMock = CurrentDateProviderMock()

                sut = BeaconIdAgent(encountersManager: encountersManagerMock,
                                    beaconIdsManager: beaconIdsManagerMock,
                                    currentDateProvider: currentDateProviderMock)
            }

            context("when new device discovered") {
                let newBeacon = BeaconId.random()
                let newBeaconRssi = Int.random(in: 0...100)
                let newEncounterDate = Date()

                beforeEach {
                    currentDateProviderMock.currentDate = newEncounterDate
                    sut.synchronizedBeaconId(beaconId: newBeacon, rssi: newBeaconRssi)
                }

                it("should pass new beacon to the encounters manager") {
                    encountersManagerMock.verifyCall(
                        withIdentifier: "addNewEncounter",
                        arguments: [Encounter.createEncounter(beaconId: newBeacon,
                                                              signalStrength: newBeaconRssi,
                                                              date: newEncounterDate)],
                        mode: .times(1))
                }
            }

            context("when asked for new beacon data") {
                beforeEach {
                    _ = sut.getBeaconId()
                }

                it("should ask for beaconIds manager") {
                    beaconIdsManagerMock.verifyCall(
                        withIdentifier: "currentExpiringBeaconId",
                        mode: .times(1))
                }
            }
        }
    }
}
