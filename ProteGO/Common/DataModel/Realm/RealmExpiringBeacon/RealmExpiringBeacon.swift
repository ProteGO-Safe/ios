import Foundation
import RealmSwift
import Realm

class RealmExpiringBeacon: Object {

    @objc dynamic var beaconIdData = Data()

    @objc dynamic var startDate = Date()

    static func createExpiringBeacon(beaconIdData: Data, date: Date) -> RealmExpiringBeacon {
        let beacon = RealmExpiringBeacon()
        beacon.beaconIdData = beaconIdData
        beacon.startDate = date

        return beacon
    }
}
