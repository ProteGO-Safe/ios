import Foundation
import Mimus
@testable import ProteGO

extension Encounter: MockEquatable {
    public func equalTo(other: Any?) -> Bool {
        guard let other = other as? Encounter else {
            return false
        }
        return self.date == other.date
            && self.deviceId == other.deviceId
            && self.signalStrength.value == other.signalStrength.value
    }
}
