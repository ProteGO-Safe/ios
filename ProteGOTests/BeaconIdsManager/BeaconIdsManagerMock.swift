import Foundation
import Mimus
import RealmSwift
@testable import ProteGO

final class BeaconIdsManagerMock: BeaconIdsManagerType, Mock {

    var allBeaconIds: Results<RealmExpiringBeacon> {
        recordCall(withIdentifier: "allBeaconIds")
        return realmManagerMock.realm.objects(RealmExpiringBeacon.self)
    }

    var storage: [RecordedCall] = []

    var currentExpiringBeaconId: ExpiringBeaconId? {
        recordCall(withIdentifier: "currentExpiringBeaconId")
        return nil
    }

    var lastStoredExpiringBeaconDate: Date? {
        recordCall(withIdentifier: "lastStoredExpiringBeaconDate")
        return nil
    }

    private let realmManagerMock = RealmManagerMock()

    func update(with response: [GetStatusResponseBeaconId]) {
        recordCall(withIdentifier: "update", arguments: [response])
    }

    func deleteAllIdsOlderThan(date: Date) throws {
        recordCall(withIdentifier: "deleteAllIdsOlderThan", arguments: [date])
    }
}
