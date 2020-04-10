import Foundation
import Mimus
@testable import ProteGO

extension DangerStatus: MockEquatable {
    public func equalTo(other: Any?) -> Bool {
        guard let other = other as? DangerStatus else {
            return false
        }
        return self.rawValue == other.rawValue
    }
}
