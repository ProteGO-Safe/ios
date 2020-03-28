import Foundation
import RealmSwift

protocol EncountersManagerType: class {
    var allEncounters: Results<Encounter> { get }

    func addNewEncounter(encounter: Encounter) throws

    func deleteAllEncountersOlderThan(date: Date) throws
}
