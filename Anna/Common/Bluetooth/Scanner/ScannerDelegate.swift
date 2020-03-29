import Foundation

protocol ScannerDelegate: AnyObject {
    /// Callback invoked when token data was successfully retrieved from the surrounding peripheral.
    ///
    /// Note: Make sure this function call is **not blocking**.
    ///
    /// - Parameter data: token data
    /// - rssi:  RSSI value if we managed fetch one.
    func synchronizedTokenData(data: Data, rssi: Int?)
}
