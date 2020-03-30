import Foundation

protocol AdvertiserDelegate: AnyObject {
    /// This function is a hint that data we want to send to other device is expired and need replacement.
    /// User may call `updateTokenData` on peripheral manager to update token data.
    /// If token data is not updated during this call, incoming request will be rejected.
    ///
    /// Note: Make sure this function call is **not blocking**.
    ///
    /// - Parameter previousTokenData: previous token data used.
    func tokenDataExpired(previousTokenData: (Data, Date)?)
}
