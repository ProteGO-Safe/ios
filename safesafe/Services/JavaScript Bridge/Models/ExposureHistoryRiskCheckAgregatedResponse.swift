//
//  ExposureHistoryRiskCheckAgregatedResponse.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 13/12/2020.
//

import Foundation

struct ExposureHistoryRiskCheckAgregatedResponse: Codable, JSONRepresentable {
    let lastRiskCheckTimestamp: Int
    let todayKeysCount: Int
    let last7daysKeysCount: Int
    let totalKeysCount: Int
    
    init(with model: ExposureHistoryRiskCheckAgregated) {
        self.lastRiskCheckTimestamp = model.lastRiskCheckTimestamp
        self.todayKeysCount = model.todayKeysCount
        self.last7daysKeysCount = model.last7daysKeysCount
        self.totalKeysCount = model.totalKeysCount
    }
}
