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
    case timeout
    
    // Login
    case signInFailed
    
    // AppManagerStatus
    case serializationFailed
    
    // JSON
    case jsonSerializingData
    
    // Files & Folders
    case locatingDictionary
    case writingToFile
    case extractingDirectoryName
    
    // Onboarding
    case waitingForUser
    case notManagableYet
    
    // DeviceCheck
    case deviceCheckTokenGenerationFailed
    
    // Remote config
    case remoteConfigNotExistingKey
    case remoteActivate
    case remoteUnknownStatus
    
    // Type casting
    case invalidDataType
    
    // Keychain
    case keychainKeyNotExists
    
    // Networking
    case cantMakeRequest
    case noInternet
    
    // Uplod
    case uploadValidation
    
    // Get diagnosis keys
    case shareKeysUserCanceled
    
    // Detect exposure
    case detectExposuresNoKeys
    
    // Free test
    case freeTestPinUploadFailed
}
