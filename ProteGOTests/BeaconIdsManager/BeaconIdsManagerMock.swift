import Foundation
import Mimus
@testable import ProteGO

final class BeaconIdsManagerMock: BeaconIdsManagerType, Mock {
    var storage: [RecordedCall] = []

    var currentExpiringBeaconId: ExpiringBeaconId? {
        recordCall(withIdentifier: "currentExpiringBeaconId")
        return nil
    }

    var lastStoredExpiringBeaconDate: Date? {
        recordCall(withIdentifier: "lastStoredExpiringBeaconDate")
        return nil
    }

    func update(with response: [GetStatusResponseBeaconId]) {
        recordCall(withIdentifier: "update", arguments: [response])
    }
}
