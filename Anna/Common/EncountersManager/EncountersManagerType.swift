import Foundation
import RealmSwift

protocol EncountersManagerType: ScannerDelegate {
    var allEncounters: Results<Encounter> { get }

    func addNewEncounter(encounter: Encounter) throws

    func deleteAllEncountersOlderThan(date: Date) throws
}
