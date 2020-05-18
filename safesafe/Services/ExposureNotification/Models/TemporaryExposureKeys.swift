//
//  TemporaryExposureKeys.swift
//  safesafe
//

import Foundation

@available(iOS 13.5, *)
struct TemporaryExposureKeys: Encodable {
    
    enum Default {
        static let regions = ["PL"]
        static let platform = "ios"
        static let transmissionRisk = 8 // TODO: verify value
        static let appPackageName = Bundle.main.bundleIdentifier!
        static let verificationAuthorityName = "GIS"
    }
    
    let temporaryExposureKeys: [TemporaryExposureKey]
    let regions = Default.regions
    let platform = Default.platform
    let transmissionRisk = Default.transmissionRisk
    let appPackageName = Default.appPackageName
    let verificationAuthorityName = Default.verificationAuthorityName
    let verificationPayload: String
    let deviceVerificationPayload: String
    
}
