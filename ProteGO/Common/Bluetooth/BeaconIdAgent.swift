import Foundation

final class BeaconIdAgent {

    private let encountersManager: EncountersManagerType

    private let beaconIdsManager: BeaconIdsManagerType

    private let currentDateProvider: CurrentDateProviderType

    init(encountersManager: EncountersManagerType,
         beaconIdsManager: BeaconIdsManagerType,
         currentDateProvider: CurrentDateProviderType) {
        self.encountersManager = encountersManager
        self.beaconIdsManager = beaconIdsManager
        self.currentDateProvider = currentDateProvider
    }
}

extension BeaconIdAgent: BeaconIdAgentType {
    func getBeaconId() -> ExpiringBeaconId? {
        return self.beaconIdsManager.currentExpiringBeaconId
    }

    func synchronizedBeaconId(beaconId: BeaconId, rssi: Int?) {
        logger.info("Synchronized Beacon ID \(beaconId), rssi: \(String(describing: rssi))")
        let newEncounter = Encounter.createEncounter(beaconId: beaconId,
                                                     signalStrength: rssi,
                                                     date: currentDateProvider.currentDate)
        do {
            try self.encountersManager.addNewEncounter(encounter: newEncounter)
        } catch {
            logger.error("Error with saving new encounter \(error)")
        }
    }
}
