import Foundation

/// Class implementing this protocol is responsible for giving out Beacon IDs and
/// receiving them and storing locally.
protocol BeaconIdAgentType: AnyObject {

    /// This function should return valid Beacon ID with its expiration date
    /// which will be exchanged between devices. Can return `nil` if there
    /// are are no valid Beacon IDs available.
    func getBeaconId() -> ExpiringBeaconId?

    /// This function is called when new Beacon ID is synchronized.
    ///
    /// - Parameters:
    ///   - beaconId: Synchronized Beacon ID
    ///   - rssi: RSSI value for a Beacon ID
    func synchronizedBeaconId(beaconId: BeaconId, rssi: Int?)
}
