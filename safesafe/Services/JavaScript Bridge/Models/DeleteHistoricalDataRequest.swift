//
//  DeleteHistoricalDataRequest.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 07/12/2020.
//

import Foundation

struct DeleteHistoricalDataRequest: Codable {
    let notifications: [String]
    let riskChecks: [String]
    let exposures: [String]
}
