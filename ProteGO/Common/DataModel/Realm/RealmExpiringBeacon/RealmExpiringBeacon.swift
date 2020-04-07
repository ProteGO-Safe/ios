import Foundation
import RealmSwift
import Realm

class RealmExpiringBeacon: Object {

    @objc dynamic var beaconIdData = Data()

    @objc dynamic var expirationDate = Date()

    static func createExpiringBeacon(beaconIdData: Data, date: Date) -> RealmExpiringBeacon {
        let beacon = RealmExpiringBeacon()
        beacon.beaconIdData = beaconIdData
        beacon.expirationDate = date

        return beacon
    }
}
