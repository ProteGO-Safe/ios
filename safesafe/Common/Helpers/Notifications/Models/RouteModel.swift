//
//  RouteModel.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 03/12/2020.
//

import Foundation

struct RouteModel: Decodable {
    let name: String
    let params: [String: Value]
    
    enum Value: Decodable {
        case int(Int)
        case string(String)
        case float(Float)
        case double(Double)
        case bool(Bool)
        case unknown
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let value = try? container.decode(Double.self) {
                self = .double(value)
            } else if let value = try? container.decode(Float.self) {
                self = .float(value)
            } else if let value = try? container.decode(Int.self) {
                self = .int(value)
            } else if let value = try? container.decode(Bool.self) {
                self = .bool(value)
            } else if let value = try? container.decode(String.self) {
                self = .string(value)
            } else {
                self = .unknown
            }
        }
    }
}
