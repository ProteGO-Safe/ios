import Foundation
import RealmSwift

final class BeaconIdsManager: BeaconIdsManagerType {

    var allBeaconIds: Results<RealmExpiringBeacon> {
        return self.realmManager.realm.objects(RealmExpiringBeacon.self)
            .sorted(byKeyPath: Constants.Realm.EntityKeys.ExpiringBeacon.startDate, ascending: true)
    }

    var lastStoredExpiringBeaconDate: Date? {
        return self.realmManager.realm.objects(RealmExpiringBeacon.self)
            .sorted(byKeyPath: Constants.Realm.EntityKeys.ExpiringBeacon.startDate, ascending: false)
            .first?
            .startDate
    }

    var currentExpiringBeaconId: ExpiringBeaconId? {
        let currentDate = currentDateProvider.currentDate

        guard let previousExpiringBeacon = self.realmManager.realm.objects(RealmExpiringBeacon.self)
            .filter("\(Constants.Realm.EntityKeys.ExpiringBeacon.startDate) <= %@", currentDate)
            .sorted(byKeyPath: Constants.Realm.EntityKeys.ExpiringBeacon.startDate, ascending: false).first else {
                // no valid beacon found
                return nil
        }

        guard let previousBeacon = BeaconId(data: previousExpiringBeacon.beaconIdData) else {
            logger.error("Incorrect beacon found \(previousExpiringBeacon.beaconIdData.toHexString())")
            return nil
        }

        guard let nextExpiringBeacon = self.realmManager.realm.objects(RealmExpiringBeacon.self)
            .filter("\(Constants.Realm.EntityKeys.ExpiringBeacon.startDate) > %@", currentDate)
            .sorted(byKeyPath: Constants.Realm.EntityKeys.ExpiringBeacon.startDate, ascending: true).first else {
                // last beacon with current date + default lifespan
                let date = currentDate.addingTimeInterval(Constants.Bluetooth.ExpiringBeaconDefaultLifespan)
                return ExpiringBeaconId(beaconId: previousBeacon,
                                        expirationDate: date,
                                        currentDateProvider: self.currentDateProvider)
        }

        // beacon with date adjusted to the next available beacon
        return ExpiringBeaconId(beaconId: previousBeacon,
                                expirationDate: nextExpiringBeacon.startDate,
                                currentDateProvider: self.currentDateProvider)
    }

    private let realmManager: RealmManagerType

    private let currentDateProvider: CurrentDateProviderType

    init(realmManager: RealmManagerType, currentDateProvider: CurrentDateProviderType) {
        self.realmManager = realmManager
        self.currentDateProvider = currentDateProvider
    }

    func update(with response: [GetStatusResponseBeaconId]) {
        do {
            try self.realmManager.realm.write { [weak self] in
                for beaconId in response {
                    let realmExpiringBeacon = RealmExpiringBeacon.createExpiringBeacon(
                        beaconIdData: beaconId.beaconId.getData(),
                        date: beaconId.date
                    )
                    self?.realmManager.realm.add(realmExpiringBeacon, update: .error)
                }
            }
        } catch {
            logger.error("Error with saving new expiring beacon ids \(error)")
        }
    }
}
