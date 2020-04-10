import Foundation

struct ExpiringBeaconId {

    let expirationDate: Date

    private let beaconId: BeaconId

    private let currentDateProvider: CurrentDateProviderType

    init(beaconId: BeaconId, expirationDate: Date, currentDateProvider: CurrentDateProviderType) {
        self.beaconId = beaconId
        self.expirationDate = expirationDate
        self.currentDateProvider = currentDateProvider
    }

    func isExpired() -> Bool {
        return expirationDate < currentDateProvider.currentDate
    }

    func getBeaconId() -> BeaconId? {
        if isExpired() {
            return nil
        }
        return beaconId
    }
}

extension ExpiringBeaconId: CustomStringConvertible {
    var description: String {
        return "(\(beaconId) exp: \(expirationDate))"
    }
}
