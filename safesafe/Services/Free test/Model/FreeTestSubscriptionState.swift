//
//  FreeTestSubscriptionState.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/10/2020.
//

import Foundation

enum FreeTestSubscriptionState: Int, Codable {
    case unverified = 0
    case verified = 1
    case signedForTest = 2
    case utilized = 3
    case unknown = 999
}
