//
//  ObservedDistrictsPWAResponseModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 12/10/2020.
//

import Foundation

struct ObservedDistrictsPWAResponseModel: Codable {
    
    let districts: [District]
    
    struct District: Codable {
        let id: Int
        let name: String
        let state: Int
    }
}
