import Foundation
import Mimus
@testable import ProteGO

extension Date: MockEquatable {
    public func equalTo(other: Any?) -> Bool {
        guard let other = other as? Date else {
            return false
        }
        return self == other
    }
}
