//
//  TemporaryExposureKey.swift
//  safesafe
//

import ExposureNotification

@available(iOS 13.5, *)
struct TemporaryExposureSingleKey: Encodable {
    
    let key: Data
    let rollingPeriod: ENIntervalNumber
    let rollingStartNumber: ENIntervalNumber
    let transmissionRisk: ENRiskLevel
    
    init(_ key: ENTemporaryExposureKey) {
        self.key = key.keyData
        rollingPeriod = key.rollingPeriod
        rollingStartNumber = key.rollingStartNumber
        
        // As requested, it should be `8` for now
        transmissionRisk = 8//key.transmissionRiskLevel
    }
    
}
