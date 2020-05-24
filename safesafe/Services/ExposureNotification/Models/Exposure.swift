//
//  Exposure.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation

final class Exposure {
    
    @objc dynamic var timestamp: Double
    @objc dynamic var risk: Int
    @objc dynamic var duration: Double
    
    init(
        timestamp: Double,
        risk: Int,
        duration: Double
    ) {
        self.timestamp = timestamp
        self.risk = risk
        self.duration = duration
    }
    
}
