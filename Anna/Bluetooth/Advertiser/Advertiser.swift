//
//  Advertiser.swift
//  Anna
//
//  Created by Przemysław Lenart on 29/03/2020.
//  Copyright © 2020 GOV. All rights reserved.
//

import Foundation

protocol Advertiser {
    /// Update advertised token data
    ///
    /// - Parameters:
    ///   - data: New token data payload
    ///   - expirationDate: Expiration date of token data
    func updateTokenData(data: Data, expirationDate: Date)
}
