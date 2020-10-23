//
//  FreeTestPinUploadResponse.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/10/2020.
//

import Foundation

struct FreeTestPinUploadResponse: Codable {
    
    enum Status: Int, Codable {
        case success = 1
        case failed = 2
        case canceled = 3
    }
    
    let result: Status
}
