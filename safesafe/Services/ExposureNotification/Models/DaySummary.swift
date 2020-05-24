//
//  DaySummary.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation

struct DaySummary: Codable {
    
    let date: Int       // EPOCH timestamp
    let riskScore: Int  // risk score normalized to 1-8
    
}
