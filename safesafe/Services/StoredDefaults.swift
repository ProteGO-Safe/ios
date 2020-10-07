//
//  StoredDefaults.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

final class StoredDefaults {
    
    static let standard = StoredDefaults()
    
    struct Key {
        let name: String
        
        init(_ name: String) {
            self.name = name
        }
    }
    
    func set(value: Any, key: Key) {
        UserDefaults.standard.set(value, forKey: key.name)
    }
    
    func get<T: Any>(key: Key) -> T? {
        return UserDefaults.standard.value(forKey: key.name) as? T
    }
    
    func delete(key: Key) {
        UserDefaults.standard.removeObject(forKey: key.name)
    }
}
