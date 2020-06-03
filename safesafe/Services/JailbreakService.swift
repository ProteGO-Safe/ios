//
//  JailbreakService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 03/06/2020.
//

import Foundation

protocol JailbreakServiceProtocol {
    
    var isJailbroken: Bool { get }
    
}

final class JailbreakService: JailbreakServiceProtocol {
    
    var isJailbroken: Bool {
        #if TARGET_IOS_SIMULATOR
            return true
        #endif
        
        let fileManager = FileManager.default
        var result = false
        
        unsafePaths
            .map { fileManager.fileExists(atPath: $0) }
            .first(where: { $0 == true })
            .map { _ in result = true }
        
        _ = unsafePaths.map {
            let file = fopen($0, "r")
            
            if file != nil {
                fclose(file)
                result = true
            }
        }
        
        do {
            try "jailbreak_test".write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)
        } catch {
            result = true
        }
        
        return result
    }
    
    private let unsafePaths = [
        "/Applications/Cydia.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/bin/bash",
        "/usr/sbin/sshd",
        "/etc/apt",
        "/usr/bin/ssh",
        "/private/var/lib/apt/"
    ]
    
}
