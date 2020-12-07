//
//  ExposureRiskCheck.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 07/12/2020.
//

import RealmSwift
import Foundation

final class ExposureHistoryAnalyzeCheck: Object, LocalStorable {
    
    struct EncodableModel: Encodable {
        let id: String
        let timestamp: Int
        let exposures: Int
        let keys: Int
    }
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date = Date()
    @objc dynamic var matchedKeyCount: Int = .zero
    @objc dynamic var keysCount: Int = .zero
    
    override class func primaryKey() -> String? { "id" }
    
    convenience init(matchedKeyCount: Int, keysCount: Int) {
        self.init()
        
        self.matchedKeyCount = matchedKeyCount
        self.keysCount = keysCount
    }
    
    func asEncodable() -> EncodableModel {
        .init(id: id, timestamp: Int(date.timeIntervalSince1970), exposures: matchedKeyCount, keys: keysCount)
    }
}
