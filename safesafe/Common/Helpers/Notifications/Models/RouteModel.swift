//
//  RouteModel.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 03/12/2020.
//

import Foundation

struct RouteModel: Decodable {
    let name: String
    var params: [String: Value]
    
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
    
    func asDictionary() -> [String: Any] {
        var dictionary: [String: Any] = ["name": name]
        var dictionaryParams: [String: Any] = [:]
        
        for param in params {
            switch param.value {
            case .int(let value):
                dictionaryParams[param.key] = value
            case .string(let value):
                dictionaryParams[param.key] = value
            case .float(let value):
                dictionaryParams[param.key] = value
            case .double(let value):
                dictionaryParams[param.key] = value
            case .bool(let value):
                dictionaryParams[param.key] = value
            case .unknown: ()
            }
        }
        
        dictionary["params"] = dictionaryParams
        return dictionary
    }
    
    func asJSONString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: asDictionary(), options: .fragmentsAllowed) else {
            return nil
        }
        
        return String(bytes: data, encoding: .utf8)
    }
}
