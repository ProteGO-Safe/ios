import Foundation

protocol Advertiser {
    /// Update advertised beacon id.
    ///
    /// - Parameters:
    ///   - beaconId: Beacon ID to synchronize.
    ///   - expirationDate: Beacon ID expiration date.
    func updateBeaconId(beaconId: BeaconId, expirationDate: Date)
}
