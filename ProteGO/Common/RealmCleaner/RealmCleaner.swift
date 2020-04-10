import Foundation
import RealmSwift

final class RealmCleaner: RealmCleanerType {

    private let encounterManager: EncountersManagerType

    private let beaconIdsManager: BeaconIdsManagerType

    private let currentDateProvider: CurrentDateProviderType

    private let dataRetentionPeriod: TimeInterval

    init(dataRetentionPeriod: TimeInterval, currentDateProvider: CurrentDateProviderType,
         encounterManager: EncountersManagerType, beaconIdsManager: BeaconIdsManagerType) {
        self.encounterManager = encounterManager
        self.beaconIdsManager = beaconIdsManager
        self.dataRetentionPeriod = dataRetentionPeriod
        self.currentDateProvider = currentDateProvider
    }

    func clean() throws {
        try self.encounterManager.deleteAllEncountersOlderThan(
            date: currentDateProvider.currentDate.addingTimeInterval(-dataRetentionPeriod))
        try self.beaconIdsManager.deleteAllIdsOlderThan(
            date: currentDateProvider.currentDate.addingTimeInterval(-dataRetentionPeriod))
        logger.info("Finished cleaning old database items")
    }
}
