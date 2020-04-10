import Foundation
import Mimus
@testable import ProteGO

extension GetStatusResponseBeaconId: MockEquatable {
    public func equalTo(other: Any?) -> Bool {
        guard let other = other as? GetStatusResponseBeaconId else {
            return false
        }
        return self.date == other.date && self.beaconId == other.beaconId
    }
}
