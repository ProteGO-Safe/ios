//
//  Exposure.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation
import RealmSwift

final class Exposure: Object, LocalStorable {
    
    @objc dynamic var id = UUID().uuidString
    
    /// Total calculated risk, range is 0-4096
    @objc dynamic var risk: Int = .zero
    
    /// Exposure duration in seconds
    @objc dynamic var duration: Double = .zero
    
    /// Date of exposure
    @objc dynamic var date: Date = Date()
    
    convenience init(
        risk: Int,
        duration: Double,
        date: Date
    ) {
        self.init()
        self.risk = risk
        self.duration = duration
        self.date = date
    }
    
}
