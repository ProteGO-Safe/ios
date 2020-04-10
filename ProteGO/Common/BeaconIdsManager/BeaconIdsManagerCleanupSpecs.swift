import Foundation
import Quick
import Nimble
import RealmSwift
@testable import ProteGO

//swiftlint:disable force_try
class BeaconIdsManagerCleanupConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("check saved beacon ids") { (sharedExampleContext: @escaping SharedExampleContext) in
            var sut: BeaconIdsManager!
            var realmManagerMock: RealmManagerMock!
            var currentDateProviderMock: CurrentDateProviderMock!
            var results: Results<RealmExpiringBeacon>!
            var currentDate: TimeInterval!
            var expectedNumberOfBeacons: Int!

            let exampleBeacons = [
                GetStatusResponseBeaconId(beaconId: BeaconId.random(), date: Date(timeIntervalSince1970: 100)),
                GetStatusResponseBeaconId(beaconId: BeaconId.random(), date: Date(timeIntervalSince1970: 200)),
                GetStatusResponseBeaconId(beaconId: BeaconId.random(), date: Date(timeIntervalSince1970: 300)),
                GetStatusResponseBeaconId(beaconId: BeaconId.random(), date: Date(timeIntervalSince1970: 400)),
                GetStatusResponseBeaconId(beaconId: BeaconId.random(), date: Date(timeIntervalSince1970: 500))
            ]

            beforeEach {
                realmManagerMock = RealmManagerMock()
                currentDateProviderMock = CurrentDateProviderMock()
                currentDate = sharedExampleContext()["date"] as? TimeInterval
                expectedNumberOfBeacons = sharedExampleContext()["expected number of beacons"] as? Int

                sut = BeaconIdsManager(realmManager: realmManagerMock, currentDateProvider: currentDateProviderMock)
            }

            beforeEach {
                sut.update(with: exampleBeacons)

                try! sut.deleteAllIdsOlderThan(date: Date.init(timeIntervalSince1970: currentDate))
                results = realmManagerMock.realm.objects(RealmExpiringBeacon.self)
                    .sorted(byKeyPath: Constants.Realm.EntityKeys.ExpiringBeacon.startDate, ascending: true)
            }

            it("there should be correct number of elements in the database") {
                expect(results.count).to(equal(expectedNumberOfBeacons))
            }

            it("correct items should be saved to the database") {
                let shift = exampleBeacons.count - expectedNumberOfBeacons
                for i in 0..<expectedNumberOfBeacons {
                    expect(results[i].beaconIdData).to(equal(exampleBeacons[shift+i].beaconId.getData()))
                    expect(results[i].startDate).to(equal(exampleBeacons[shift+i].date))
                }
            }
        }
    }
}

class BeaconIdsManagerCleanupSpecs: QuickSpec {
    override func spec() {
        describe("BeaconIdsManager") {

            context("deleting old beacons with newer beacons in the DB") {
                itBehavesLike("check saved beacon ids") { ["date": 350.0,
                                                           "expected number of beacons": 2] }
            }

            context("deleting old beacons when there isn't anything to delete") {
                itBehavesLike("check saved beacon ids") { ["date": 0.0,
                                                           "expected number of beacons": 5] }
            }

            context("deleting old beacons when there are no new beacons available") {
                // we should save last beacon, even if it have expired
                itBehavesLike("check saved beacon ids") { ["date": 1000.0,
                                                           "expected number of beacons": 1] }
            }
        }
    }
}
