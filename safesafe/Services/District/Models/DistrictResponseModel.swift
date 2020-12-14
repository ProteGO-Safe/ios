//
//  DistrictResponseModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/10/2020.
//

import Foundation

struct DistrictResponseModel: Codable {
    
    enum CodingKeys: String, CodingKey {
        case voivodeshipsUpdated = "voivodeships_updated"
        case voivodeships
    }
    
    let voivodeshipsUpdated: Int
    let voivodeships: [Voivodeship]
    
    struct Voivodeship: Codable {
        let id: Int
        let name: String
        let districts: [District]
        
        struct District: Codable {
            let id: Int
            let name: String
            let state: Int
        }
    }
}
