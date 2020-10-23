//
//  RquestHeader.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/10/2020.
//

import Foundation

protocol RequestHeader: Codable {
    var asDictionary: [String: String] { get }
}

extension RequestHeader {
    var asDictionary: [String: String] {
        guard
            let data = try? JSONEncoder().encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
        else { return [:] }
        
        return dictionary
    }
}
