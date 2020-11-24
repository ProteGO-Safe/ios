//
//  FreeTestHeader.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/10/2020.
//

import Foundation

struct FreeTestRequestHeader: Codable, RequestHeader {
    
    enum CodingKeys: String, CodingKey {
        case deviceCheckToken = "Safety-Token"
        case userAgent = "User-Agent"
        case accessToken = "Authorization"
    }
    
    let deviceCheckToken: String
    let userAgent = "ios"
    let accessToken: String?
    
    init(deviceCheckToken: String,  accessToken: String? = nil) {
        self.deviceCheckToken = deviceCheckToken
        if let accessToken = accessToken {
            self.accessToken = "Bearer \(accessToken)"
        } else {
            self.accessToken = nil
        }
    }
}
