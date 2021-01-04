//
//  ExposureHistoryRiskCheck.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 07/12/2020.
//

import Foundation
import RealmSwift

final class ExposureHistoryRiskCheck: Object, LocalStorable {
    
    struct EncodableModel: Encodable {
        let id: String
        let timestamp: Int
        let exposures: Int
        let riskLevel: Int
    }
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date = Date()
    @objc dynamic var matchedKeyCount: Int = .zero
    @objc dynamic var riskLevelFull: Int = .zero
    
    override class func primaryKey() -> String? { "id" }
    
    convenience init(matchedKeyCount: Int, riskLevelFull: Int) {
        self.init()
        self.matchedKeyCount = matchedKeyCount
        self.riskLevelFull = riskLevelFull
    }
    
    func asEncodable() -> EncodableModel {
        let level = RiskLevel(fromFullRangeScore: riskLevelFull)
        
        return .init(id: id, timestamp: Int(date.timeIntervalSince1970), exposures: matchedKeyCount, riskLevel: level.rawValue)
    }
}
