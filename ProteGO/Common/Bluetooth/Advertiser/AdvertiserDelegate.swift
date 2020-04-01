import Foundation

protocol AdvertiserDelegate: AnyObject {
    /// This function is informs that beacon ID we want to send to other device is expired and need replacement.
    /// User should call `updateBeaconId` on advertiser to update beacon id.
    /// If beacon ID is not updated during this call, incoming request will be rejected.
    ///
    /// Note: Make sure this function call is **not blocking**.
    ///
    /// - Parameter previousBeaconId: previous beacon ID used.
    func beaconIdExpired(previousBeaconId: (BeaconId, Date)?)
}
