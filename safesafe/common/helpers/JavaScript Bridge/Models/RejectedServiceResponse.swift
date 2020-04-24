//
//  RejectedServiceResponse.swift
//  safesafe
//
//  Created by Rafał Małczyński on 23/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

enum RejectedService: String, Codable {
    
    case bluetooth
    case notification
    
}

struct RejectedServiceResponse: Codable {
    
    var rejectedService: RejectedService
    
}
