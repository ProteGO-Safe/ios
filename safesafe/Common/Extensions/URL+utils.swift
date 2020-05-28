//
//  URL+utils.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

extension URL {
    
    static let emptyFilePath = URL(string: "file://")!
    
    static func build(scheme: String, host: String, port: Int? = nil) -> URL? {
        var components = URLComponents()
        components.host = host
        components.scheme = scheme
        components.port = port
        
        return components.url
    }
    
    func isHostEqual(to otherHost: String) -> Bool {
        guard let host = self.host else {
            return false
        }
        
        return host == otherHost
    }
}
