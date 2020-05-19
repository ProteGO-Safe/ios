//
//  JSONReprestable.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 19/05/2020.
//

import Foundation

protocol JSONRepresentable: Codable {
    var jsonString: String? { get }
}

extension JSONRepresentable {
    var jsonString: String? {
        guard
            let data = try? JSONEncoder().encode(self),
            let json = String(data: data, encoding: .utf8)
        else {  return nil }
        
        return json
    }
}
