import Foundation
import RealmSwift

final class EncountersManager: EncountersManagerType {
    // NOTE: Move somewhere else...
    var lastExpiringBeaconId: ExpiringBeaconId?

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

extension EncountersManager: BeaconIdAgent {
    func getBeaconId() -> ExpiringBeaconId? {
        // NOTE: Get real values later...
        if self.lastExpiringBeaconId?.isExpired() ?? true {
            let expiringBeaconId = ExpiringBeaconId(
                  beaconId: BeaconId.random(),
                  expirationDate: Date(timeIntervalSinceNow: 60 * 60)
            )
            logger.info("Got expiring Beacon ID: \(expiringBeaconId)")
            self.lastExpiringBeaconId = expiringBeaconId
            return expiringBeaconId
        }

        return self.lastExpiringBeaconId
    }

    func synchronizedBeaconId(beaconId: BeaconId, rssi: Int?) {
        logger.info("Synchronized Beacon ID \(beaconId), rssi: \(String(describing: rssi))")
        let deviceId = beaconId.getData().toHexString()
        let newEncounter = Encounter.createEncounter(deviceId: deviceId, signalStrength: rssi, date: Date())
        do {
            try self.addNewEncounter(encounter: newEncounter)
        } catch {
            logger.error("Error with saving new encounter \(error)")
        }
    }
}
