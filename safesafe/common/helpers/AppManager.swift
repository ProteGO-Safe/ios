//
//  AppManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

class AppManager {
    static let instance = AppManager()
    
    private let defaults = StoredDefaults.standard
    
    var isFirstRun: Bool {
        return defaults.get(key: .isFirstRun) ?? false
    }
    
    var isBluetraceAllowed: Bool {
        return defaults.get(key: .isBluetraceAllowed) ?? false
    }
    
    private init() {}
}

extension StoredDefaults.Key {
    static let isFirstRun = StoredDefaults.Key("isFirstRun")
    static let isBluetraceAllowed = StoredDefaults.Key("isBluetraceAllowed")
}
