//
//  ExposureSummary.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation

struct ExposureSummary: Encodable {
    
    /**
     Risk score normalized to range of 1-3.
     
     Value is calculated based on **totalRiskScoreFullRange** from `ENExposureInfo`.
     Risk score equals:
     - 1, when `totalRiskScoreFullRange` is in `0-1499`
     - 2, when `totalRiskScoreFullRange` is in `1500-2999`
     - 3, when `totalRiskScoreFullRange` is in `3000-4096`
     */
    let riskLevel: RiskLevel
    
}

extension ExposureSummary {
 
    /// Creates `ExposureSummary` based on values of `totalRiskScoreFullRange` from range 0-4096
    init?(fromFullRangeScore score: Int) {
        switch score {
        case 0...1499:
            self.riskLevel = .low
            
        case 1500...2999:
            self.riskLevel = .medium
            
        case 3000...4096:
            self.riskLevel = .high
            
        default:
            return nil
        }
    }
    
}
