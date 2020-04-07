import Foundation
import RealmSwift
import Realm
import Mimus
@testable import ProteGO

final class EncountersManagerMock: EncountersManagerType, Mock {

    var storage: [RecordedCall] = []

    var allEncounters: Results<Encounter> {
        return self.realmManagerMock.realm.objects(Encounter.self)
    }

    func addNewEncounter(encounter: Encounter) throws {
        recordCall(withIdentifier: "addNewEncounter", arguments: [encounter])
    }

    func deleteAllEncountersOlderThan(date: Date) throws {
        recordCall(withIdentifier: "deleteAllEncountersOlderThan", arguments: [date])
    }

    func uniqueEncountersSince(date: Date) -> Results<Encounter> {
        recordCall(withIdentifier: "uniqueEncountersSince", arguments: [date])
        return self.realmManagerMock.realm.objects(Encounter.self)
    }

    private let realmManagerMock = RealmManagerMock()
}
