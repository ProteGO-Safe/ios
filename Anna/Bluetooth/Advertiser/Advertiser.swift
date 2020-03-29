import Foundation

protocol Advertiser {
    /// Update advertised token data
    ///
    /// - Parameters:
    ///   - data: New token data payload
    ///   - expirationDate: Expiration date of token data
    func updateTokenData(data: Data, expirationDate: Date)
}
