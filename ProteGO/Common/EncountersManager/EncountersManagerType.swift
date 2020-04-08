import Foundation
import RealmSwift

protocol EncountersManagerType {
    var allEncounters: Results<Encounter> { get }

    func addNewEncounter(encounter: Encounter) throws

    func deleteAllEncountersOlderThan(date: Date) throws

    func uniqueEncountersSince(date: Date) -> Results<Encounter>
}
