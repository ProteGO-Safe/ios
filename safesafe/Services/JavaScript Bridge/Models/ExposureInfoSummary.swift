//
//  ExposureInfoSummary.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation

struct ExposureInfoSummary: Encodable {
    
    let exposureNotificationStatistics: [DaySummary]
    
}
