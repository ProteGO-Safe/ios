//
//  InternalError.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 20/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

enum InternalError: Error {
    
    // Common
    case deinitialized
    case nilValue
    
    // Login
    case signInFailed
    
    // AppManagerStatus
    case serializationFailed
    
    // JSON
    case jsonSerializingData
    
    // Files & Folders
    case locatingDictionary
    case writingToFile
    
    // DeviceCheck
    case deviceCheckTokenGenerationFailed
    
    // Remote config
    case remoteConfigNotExistingKey
    case remoteActivate
    case remoteUnknownStatus
}
