//
//  TemporaryExposureKeysAuthResponse.swift
//  safesafe
//

import Foundation

struct TemporaryExposureKeysAuthResponse: Decodable {
    
    struct TemporaryExposureKeysToken: Decodable {
        let accessToken: String
    }
    
    let result: TemporaryExposureKeysToken
    
}
