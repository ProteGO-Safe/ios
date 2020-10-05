//
//  UploadTemporaryExposureKeysStatusResult.swift
//  safesafe
//

import Foundation

enum UploadTemporaryExposureKeysStatus: Int, Encodable {
    case success = 1
    case failure = 2
    case other = 3
    case canceled = 5
}

struct UploadTemporaryExposureKeysStatusResult: Encodable {
    
    let result: UploadTemporaryExposureKeysStatus
    
}
