//
//  StoredDefaults.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

public final class StoredDefaults {
    
    private enum Constants {
        static let appGroupIdentifier = "group.pl.gov.mc.protegosafe"
    }
    
    static let standard = StoredDefaults()
    
    public struct Key {
        let name: String
        
        init(_ name: String) {
            self.name = name
        }
    }
    
    
    func set(value: Any, key: Key, useAppGroup: Bool = false) {
        defaults(useAppGroup).set(value, forKey: key.name)
    }
    
    func get<T: Any>(key: Key, useAppGroup: Bool = false) -> T? {
        defaults(useAppGroup).value(forKey: key.name) as? T
    }
    
    func delete(key: Key, useAppGroup: Bool = false) {
       defaults(useAppGroup).removeObject(forKey: key.name)
    }
    
    private func defaults(_ useAppGroup: Bool = false) -> UserDefaults {
        if useAppGroup, let appGroupDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier) {
           return appGroupDefaults
        }
        
        return .standard
    }
}
