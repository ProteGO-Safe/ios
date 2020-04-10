import Foundation
import RealmSwift

final class EncountersManager: EncountersManagerType {

    var allEncounters: Results<Encounter> {
        return self.realmManager.realm.objects(Encounter.self).sorted(byKeyPath: "date", ascending: true)
    }

    func addNewEncounter(encounter: Encounter) throws {
        try self.realmManager.realm.write { [weak self] in
            self?.realmManager.realm.add(encounter, update: .error)
        }
    }

    func deleteAllEncountersOlderThan(date: Date) throws {
        try self.realmManager.realm.write {  [weak self] in
            guard let self = self else {
                throw InstanceError.deallocated(#file, #line)
            }

            let objectsToDelete = self.realmManager.realm.objects(Encounter.self).filter("date < %@", date)
            self.realmManager.realm.delete(objectsToDelete)
            logger.info("Finished deleting old enconters")
        }
    }

    func uniqueEncountersSince(date: Date) -> Results<Encounter> {
        return self.realmManager.realm.objects(Encounter.self)
            .filter("date > %@", date)
            .distinct(by: ["deviceId"])
    }

    private let realmManager: RealmManagerType

    init(realmManager: RealmManagerType) {
        self.realmManager = realmManager
    }
}
