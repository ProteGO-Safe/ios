//
//  TemporaryExposureKeysAuthData.swift
//  safesafe
//

import Foundation

struct TemporaryExposureKeysAuthData: Encodable {
    
    struct TemporaryExposureKeysAuthCode: Encodable {
        let code: String
    }
    
    let data: TemporaryExposureKeysAuthCode
    
    init(code: String) {
        data = TemporaryExposureKeysAuthCode(code: code)
    }
    
}
