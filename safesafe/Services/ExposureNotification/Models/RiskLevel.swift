//
//  RiskLevel.swift
//  safesafe
//
//  Created by Rafał Małczyński on 25/05/2020.
//

enum RiskLevel: Int, Encodable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    
    init(fromFullRangeScore score: Int) {
        switch score {
        case 1...1499:
            self = .low
            
        case 1500...2999:
            self = .medium
            
        case 3000...:
            self = .high
            
        default:
            self = .none
        }
    }
}
