import Foundation
import Quick
import Nimble
@testable import ProteGO

//swiftlint:disable force_try
class RealmCleanerSpecs: QuickSpec {
    override func spec() {
        describe("RealmCleaner") {
            var sut: RealmCleaner!
            var encountersManagerMock: EncountersManagerMock!
            var beaconIdsManagerMock: BeaconIdsManagerMock!
            var currentDateProvider: CurrentDateProviderMock!
            let dataRetentionPeriod: TimeInterval = 100
            let currentDate = Date.init(timeIntervalSince1970: 1000)

            beforeEach {
                encountersManagerMock = EncountersManagerMock()
                beaconIdsManagerMock = BeaconIdsManagerMock()
                currentDateProvider = CurrentDateProviderMock()
                sut = RealmCleaner(dataRetentionPeriod: dataRetentionPeriod,
                                   currentDateProvider: currentDateProvider,
                                   encounterManager: encountersManagerMock,
                                   beaconIdsManager: beaconIdsManagerMock)
            }

            context("when invoking data cleanup") {
                beforeEach {
                    currentDateProvider.currentDate = currentDate
                    try! sut.clean()
                }

                it("should invoke old encounters cleaning method") {
                    encountersManagerMock.verifyCall(
                        withIdentifier: "deleteAllEncountersOlderThan",
                        arguments: [currentDate.addingTimeInterval(-dataRetentionPeriod)],
                        mode: .times(1))
                }

                it("should invoke old beacon ids cleaning method") {
                    beaconIdsManagerMock.verifyCall(
                        withIdentifier: "deleteAllIdsOlderThan",
                        arguments: [currentDate.addingTimeInterval(-dataRetentionPeriod)],
                        mode: .times(1))
                }
            }
        }
    }
}
