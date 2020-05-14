//
//  TemporaryExposureKey.swift
//  safesafe
//

import ExposureNotification

struct TemporaryExposureKey: Encodable {
    
    let keyData: Data
    let rollingPeriod: ENIntervalNumber
    let rollingStartNumber: ENIntervalNumber
    
    init(_ key: ENTemporaryExposureKey) {
        keyData = key.keyData
        rollingPeriod = key.rollingPeriod
        rollingStartNumber = key.rollingStartNumber
    }
    
}
