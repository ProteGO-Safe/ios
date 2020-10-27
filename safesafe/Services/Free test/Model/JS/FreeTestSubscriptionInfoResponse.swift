//
//  FreeTestSubscriptionInfoResponse.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/10/2020.
//

import Foundation

struct FreeTestSubscriptionInfoResponse: Codable, JSONRepresentable {
    
    static let empty = FreeTestSubscriptionInfoResponse()
    
    let subscription: Subscription?
    
    struct Subscription: Codable {
        let guid: String
        let status: FreeTestSubscriptionState
        let updated: Int
    }
    
    init () {
        self.subscription = nil
    }
    
    init(with guid: DeviceGUIDModel) {
        self.subscription = .init(
            guid: guid.uuid,
            status: guid.stateEnum,
            updated: guid.update
        )
    }
}
