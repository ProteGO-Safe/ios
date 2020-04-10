import Foundation
import Quick
import Nimble
import RealmSwift
@testable import ProteGO

class BeaconIdsManagerGeneralSpecs: QuickSpec {
    //swiftlint:disable function_body_length
    override func spec() {
        describe("BeaconIdsManager") {
            var sut: BeaconIdsManager!
            var realmManagerMock: RealmManagerMock!
            var currentDateProviderMock: CurrentDateProviderMock!
            var results: Results<RealmExpiringBeacon>!

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

                sut = BeaconIdsManager(realmManager: realmManagerMock, currentDateProvider: currentDateProviderMock)
            }

            context("when db is empty") {
                it("should't return anything") {
                    expect(sut.currentExpiringBeaconId).to(beNil())
                }

                it("shouldn't return newest beacon date") {
                    expect(sut.lastStoredExpiringBeaconDate).to(beNil())
                }
            }

            context("when updated with list of beacons") {
                beforeEach {
                    sut.update(with: exampleBeacons)
                }

                context("last stored date") {
                    it("should equal youngest stored beacon date") {
                        expect(sut.lastStoredExpiringBeaconDate).to(equal(exampleBeacons[4].date))
                    }
                }

                context("saving to the database") {
                    beforeEach {
                        results = realmManagerMock.realm.objects(RealmExpiringBeacon.self)
                            .sorted(byKeyPath: Constants.Realm.EntityKeys.ExpiringBeacon.startDate, ascending: true)
                    }

                    it("there should be correct number of elements in the database") {
                        expect(results.count).to(equal(5))
                    }

                    it("correct items should be saved to the database") {
                        for i in 0..<exampleBeacons.count {
                            expect(results[i].beaconIdData).to(equal(exampleBeacons[i].beaconId.getData()))
                            expect(results[i].startDate).to(equal(exampleBeacons[i].date))
                        }
                    }
                }

                context("obtaining current expiring beacon") {
                    var returnedExpiringBeaconId: ExpiringBeaconId?
                    var currentDate: Date!

                    context("when date have passed all of the beacons stored in the DB") {
                        beforeEach {
                            currentDate = Date(timeIntervalSince1970: 1000)
                            currentDateProviderMock.currentDate = currentDate
                            returnedExpiringBeaconId = sut.currentExpiringBeaconId
                        }

                        it("should return something") {
                            expect(returnedExpiringBeaconId).toNot(beNil())
                        }

                        context("should return newest beacon") {
                            it("with proper data") {
                                expect(returnedExpiringBeaconId?.getBeaconId()?.getData())
                                    .to(equal(exampleBeacons[4].beaconId.getData()))
                            }

                            it("with default expiration date") {
                                let expectedDate = currentDate
                                    .addingTimeInterval(Constants.Bluetooth.ExpiringBeaconDefaultLifespan)
                                expect(returnedExpiringBeaconId?.expirationDate).to(equal(expectedDate))
                            }
                        }
                    }

                    context("when we have some beacons in the database, but none of them is ready yet") {
                        beforeEach {
                            currentDate = Date(timeIntervalSince1970: 0)
                            currentDateProviderMock.currentDate = currentDate
                            returnedExpiringBeaconId = sut.currentExpiringBeaconId
                        }

                        it("shouldn't return anything") {
                            expect(returnedExpiringBeaconId).to(beNil())
                        }
                    }

                    context("when we some beacons in the database and we somehting older and younger than current date") {
                        beforeEach {
                            currentDate = Date(timeIntervalSince1970: 350)
                            currentDateProviderMock.currentDate = currentDate
                            returnedExpiringBeaconId = sut.currentExpiringBeaconId
                        }

                        it("should return something") {
                            expect(returnedExpiringBeaconId).toNot(beNil())
                        }

                        context("should return proper beacon") {
                            it("with proper data") {
                                expect(returnedExpiringBeaconId?.getBeaconId()?.getData())
                                    .to(equal(exampleBeacons[2].beaconId.getData()))
                            }

                            it("with default proper expiration date") {
                                let expectedDate = Date(timeIntervalSince1970: 400)
                                expect(returnedExpiringBeaconId?.expirationDate).to(equal(expectedDate))
                            }
                        }
                    }
                }
            }
        }
    }
}
