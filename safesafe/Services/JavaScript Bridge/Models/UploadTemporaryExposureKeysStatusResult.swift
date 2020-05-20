//
//  UploadTemporaryExposureKeysStatusResult.swift
//  safesafe
//

import Foundation

enum UploadTemporaryExposureKeysStatus: Int, Encodable {
    case success = 1
    case failure
    case other
}

struct UploadTemporaryExposureKeysStatusResult: Encodable {
    
    let result: UploadTemporaryExposureKeysStatus
    
}
