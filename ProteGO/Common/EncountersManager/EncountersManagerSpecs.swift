import Foundation
import Quick
import Nimble
import RealmSwift
@testable import ProteGO

//swiftlint:disable force_try function_body_length
class EncountersManagerSpecs: QuickSpec {
    override func spec() {
        describe("EncountersManager") {
            var sut: EncountersManager!
            var realmMock: RealmManagerMock!

            let mockEncounters = [
                Encounter.createEncounter(deviceId: "encounter1", signalStrength: 10, date: Date(timeIntervalSince1970: 1)),
                Encounter.createEncounter(deviceId: "encounter2", signalStrength: 20, date: Date(timeIntervalSince1970: 2)),
                Encounter.createEncounter(deviceId: "encounter3", signalStrength: 30, date: Date(timeIntervalSince1970: 3))
            ]

            var encountersList: Results<Encounter>!

            beforeEach {
                realmMock = RealmManagerMock()
                // TODO: check why we can't use UUID().uuidString (we get Realm exceltions when adding sth to the DB)
                realmMock.realmId = "EncountersManagerSpecs"
                sut = EncountersManager(realmManager: realmMock)
            }

            context("after initialization") {
                beforeEach {
                    encountersList = sut.allEncounters
                }

                it("should be empty") {
                    expect(encountersList.count).to(equal(0))
                }
            }

            context("creating new encounters") {
                context("adding 1 encounter") {
                    beforeEach {
                        try! sut.addNewEncounter(encounter: mockEncounters[0])
                        encountersList = sut.allEncounters
                    }

                    it("should return single encounter with proper values") {
                        expect(encountersList.count).to(equal(1))

                        if encountersList.count == 1 {
                            expect(encountersList[0].deviceId).to(equal(mockEncounters[0].deviceId))
                            expect(encountersList[0].signalStrength.value).to(equal(mockEncounters[0].signalStrength.value))
                            expect(encountersList[0].date).to(equal(mockEncounters[0].date))
                        }
                    }
                }

                context("adding multiple encounters") {
                    beforeEach {
                        try! sut.addNewEncounter(encounter: mockEncounters[0])
                        try! sut.addNewEncounter(encounter: mockEncounters[1])
                        try! sut.addNewEncounter(encounter: mockEncounters[2])
                        encountersList = sut.allEncounters
                    }

                    it("should return correct encounters with proper properties") {
                        expect(encountersList.count).to(equal(3))

                        if encountersList.count == 3 {
                            expect(encountersList[0].deviceId).to(equal(mockEncounters[0].deviceId))
                            expect(encountersList[1].deviceId).to(equal(mockEncounters[1].deviceId))
                            expect(encountersList[2].deviceId).to(equal(mockEncounters[2].deviceId))
                            expect(encountersList[0].signalStrength.value).to(equal(mockEncounters[0].signalStrength.value))
                            expect(encountersList[1].signalStrength.value).to(equal(mockEncounters[1].signalStrength.value))
                            expect(encountersList[2].signalStrength.value).to(equal(mockEncounters[2].signalStrength.value))
                            expect(encountersList[0].date).to(equal(mockEncounters[0].date))
                            expect(encountersList[1].date).to(equal(mockEncounters[1].date))
                            expect(encountersList[2].date).to(equal(mockEncounters[2].date))
                        }
                    }
                }

                context("deleting encounters") {
                    beforeEach {
                        try! sut.addNewEncounter(encounter: mockEncounters[0])
                        try! sut.addNewEncounter(encounter: mockEncounters[1])
                        try! sut.addNewEncounter(encounter: mockEncounters[2])
                        // delete first encounter
                        try! sut.deleteAllEncountersOlderThan(date: mockEncounters[1].date)
                        encountersList = sut.allEncounters
                    }

                    it("should return correct number of encounters") {
                        expect(encountersList.count).to(equal(2))

                        if encountersList.count == 2 {
                            expect(encountersList[0].deviceId).to(equal(mockEncounters[1].deviceId))
                            expect(encountersList[1].deviceId).to(equal(mockEncounters[2].deviceId))
                            expect(encountersList[0].signalStrength.value).to(equal(mockEncounters[1].signalStrength.value))
                            expect(encountersList[1].signalStrength.value).to(equal(mockEncounters[2].signalStrength.value))
                            expect(encountersList[0].date).to(equal(mockEncounters[1].date))
                            expect(encountersList[1].date).to(equal(mockEncounters[2].date))
                        }
                    }
                }

            }

        }
    }
}
