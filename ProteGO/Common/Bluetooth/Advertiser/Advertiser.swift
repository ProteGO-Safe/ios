import Foundation

protocol Advertiser {
    /// Set advertiser mode deciding how long advertisement is turned on and off.
    /// - Parameter mode: Advertiser mode
    func setMode(_ mode: AdvertiserMode)

    /// Get advertiser mode.
    func getMode() -> AdvertiserMode

    /// Returns true if advertiser is enabled and advertising.
    func isAdvertising() -> Bool
}
