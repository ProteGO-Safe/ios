import Foundation

struct ExpiringBeaconId {
    private let beaconId: BeaconId
    private let expirationDate: Date

    init(beaconId: BeaconId, expirationDate: Date) {
        self.beaconId = beaconId
        self.expirationDate = expirationDate
    }

    func isExpired() -> Bool {
        return expirationDate < Date()
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
