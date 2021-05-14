//
//  FreeTestHeader.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/10/2020.
//

import Foundation

struct FreeTestRequestHeader: Codable, RequestHeader {

    // MARK: - Properties

    enum CodingKeys: String, CodingKey {
        case userAgent = "User-Agent"
        case accessToken = "Authorization"
    }
    
    let userAgent = "ios"
    let accessToken: String?

    // MARK: - Initialization

    init(accessToken: String? = nil) {
        if let accessToken = accessToken {
            self.accessToken = "Bearer \(accessToken)"
        } else {
            self.accessToken = nil
        }
    }
}
