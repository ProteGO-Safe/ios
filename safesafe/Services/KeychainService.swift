//
//  KeyChain.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 24/05/2020.
//

import Foundation
import KeychainAccess

final class KeychainService {
    static let shared = KeychainService()
    
    private let keychain: Keychain
    
    private init() {
        self.keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "pl.gov.mc.protegosafe")
    }
    
    func set(value: String, for key: Key) {
        try? keychain.set(value, key: key.name)
    }
    
    func set(data: Data, for key: Key) {
        try? keychain.set(data, key: key.name)
    }
    
    func getValue(for key: Key) -> String? {
        return try? keychain.get(key.name)
    }
    
    func getData(for key: Key) -> Data? {
        return try? keychain.getData(key.name)
    }
}

extension KeychainService {
    struct Key {
        let name: String
        
        init(_ name: String) {
            self.name = name
        }
    }
}
