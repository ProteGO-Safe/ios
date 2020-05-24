//
//  Exposure.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation
import RealmSwift

final class Exposure: Object, LocalStorable {
    
    /// Epoch time in seconds
    @objc dynamic var timestamp: Double = .zero
    
    /// Total calculated risk, range is 0-4096
    @objc dynamic var risk: Int = .zero
    
    /// Exposure duration in seconds
    @objc dynamic var duration: Double = .zero
    
    convenience init(timestamp: Double, risk: Int, duration: Double) {
        self.init()
        self.timestamp = timestamp
        self.risk = risk
        self.duration = duration
    }
    
}
