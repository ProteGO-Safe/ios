import Foundation

protocol AdvertiserDelegate: AnyObject {
    /// Callback invoked when Beacon ID was successfully retrieved from the surrounding device.
    ///
    /// Note: Make sure this function call is **not blocking**.
    ///
    /// - Parameters:
    ///   - beaconId: synchronized Beacon ID with other device.
    ///   - rssi: RSSI detected during synchronization if available
    func synchronizedBeaconId(beaconId: BeaconId, rssi: Int?)

    /// This function informs that last Beacon ID is expired and need replacement.
    /// User should call `updateBeaconId` on advertiser to update Beacon ID.
    /// If Beacon ID is not updated during this call, incoming requests will be rejected.
    ///
    /// Note: Make sure this function call is **not blocking**.
    ///
    /// - Parameter previousBeaconId: previous Beacon ID used.
    func beaconIdExpired(previousBeaconId: (BeaconId, Date)?)
}
