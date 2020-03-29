import Foundation
import RealmSwift
import Realm

class Encounter: Object {

    @objc dynamic var deviceId: String = ""

    dynamic var signalStrength = RealmOptional<Int>()

    @objc dynamic var date = Date()

    static func createEncounter(deviceId: String, signalStrength: Int?, date: Date) -> Encounter {
        let encounter = Encounter()
        encounter.deviceId = deviceId
        encounter.signalStrength.value = signalStrength
        encounter.date = date

        return encounter
    }
}
