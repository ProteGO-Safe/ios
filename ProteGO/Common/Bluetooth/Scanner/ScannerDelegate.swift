import Foundation

protocol ScannerDelegate: AnyObject {
    /// Callback invoked when beacon id was successfully retrieved from the surrounding device.
    ///
    /// Note: Make sure this function call is **not blocking**.
    ///
    /// - Parameters:
    ///   - beaconId: synchronized beacon ID with other device.
    ///   - rssi: RSSI detected during synchronization if available
    func synchronizedBeaconId(beaconId: BeaconId, rssi: Int?)
}
