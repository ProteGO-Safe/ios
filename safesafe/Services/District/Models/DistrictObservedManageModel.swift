//
//  DistrictObservedManageModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/10/2020.
//

import Foundation

struct DistrictObservedManageModel: Codable {
    
    enum OperationType: Int, Codable {
        case add = 1
        case delete = 2
    }
    
    let districtId: Int
    let type: OperationType
}
