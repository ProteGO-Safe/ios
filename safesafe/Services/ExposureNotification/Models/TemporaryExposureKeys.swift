//
//  TemporaryExposureKeys.swift
//  safesafe
//

import Foundation

struct TemporaryExposureKeys: Encodable {
    
    let temporaryExposureKeys: [TemporaryExposureKey]
    let regions = ["PL"]
    let platform = "ios"
    let transmissionRisk = 9
    let appPackageName = Bundle.main.bundleIdentifier
    let verificationAuthorityName = "GIS"
    let verificationPayload = "PL_PGS"
    let deviceVerificationPayload: String
    
}
