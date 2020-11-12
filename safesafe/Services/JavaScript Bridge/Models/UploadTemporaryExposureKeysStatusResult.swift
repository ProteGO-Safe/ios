//
//  UploadTemporaryExposureKeysStatusResult.swift
//  safesafe
//

import Foundation

enum UploadTemporaryExposureKeysStatus: Int, Encodable {
    case success = 1
    case failure = 2
    case canceled = 3
    case noInternet = 4
    case accessDenied = 5
}

struct UploadTemporaryExposureKeysStatusResult: Encodable {
    
    let result: UploadTemporaryExposureKeysStatus
    
}
