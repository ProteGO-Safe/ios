//
//  FreeTestSubscriptionInfoResponse.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/10/2020.
//

import Foundation

struct FreeTestSubscriptionInfoResponse: Codable, JSONRepresentable {
    
    let subscription: Subscription
    
    struct Subscription: Codable {
        let guid: String
        let status: FreeTestSubscriptionState
        let updated: Int
    }
}
