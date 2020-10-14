//
//  DistrictsPWAResponseModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/10/2020.
//

import Foundation

struct DistrictsPWAResponseModel: Codable {
    
    enum ResultType: Int, Codable {
        case success = 1
        case failed = 2
    }
    
    let result: ResultType
    let updated: Int
    let voivodeships: [Voivodeship]
    
    struct Voivodeship: Codable {
        let id: Int
        let name: String
        let districts: [District]
        
        struct District: Codable {
            let id: Int
            let name: String
            let state: Int
            let isSubscribed: Bool
        }
    }
}
