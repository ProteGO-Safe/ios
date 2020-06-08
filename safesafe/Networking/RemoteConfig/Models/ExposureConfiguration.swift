//
//  ExposureConfiguration.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/05/2020.
//

import Foundation

struct ExposureConfiguration: Decodable {
    let minimumRiskScore: Int
    let attenuationWeigh: Int
    let daysSinceLastExposureWeight: Int
    let durationWeight: Int
    let transmissionRiskWeight: Int
    let attenuationScores: [Int]
    let daysSinceLastExposureScores: [Int]
    let durationScores: [Int]
    let transmissionRiskScores: [Int]
    let durationAtAttenuationThresholds: [Int]
}
