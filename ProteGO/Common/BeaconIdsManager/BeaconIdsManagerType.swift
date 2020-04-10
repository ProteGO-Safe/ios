import Foundation
import RealmSwift

protocol BeaconIdsManagerType: class {
    var allBeaconIds: Results<RealmExpiringBeacon> { get }

    var currentExpiringBeaconId: ExpiringBeaconId? { get }

    var lastStoredExpiringBeaconDate: Date? { get }

    func update(with response: [GetStatusResponseBeaconId])

    func deleteAllIdsOlderThan(date: Date) throws
}
