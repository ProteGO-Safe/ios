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
        }
    }

    private let realmManager: RealmManagerType

    init(realmManager: RealmManagerType) {
        self.realmManager = realmManager
    }
}

extension EncountersManager: ScannerDelegate {
    func synchronizedTokenData(data: Data, rssi: Int?) {
        logger.debug("Synchronized token data \(data), rssi: \(String(describing: rssi))")
        let deviceId = data.map { String(format: "%02hhx", $0) }.joined()
        let newEncounter = Encounter.createEncounter(deviceId: deviceId, signalStrength: rssi, date: Date())
        do {
            try self.addNewEncounter(encounter: newEncounter)
        } catch {
            logger.error("Error with saving new encounter \(error)")
        }
    }
}
