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
        static let appPackageName = Bundle.main.bundleIdentifier!
    }
    
    let temporaryExposureKeys: [TemporaryExposureKey]
    let regions = Default.regions
    let platform = Default.platform
    let appPackageName = Default.appPackageName
    let verificationPayload: String
    
}
