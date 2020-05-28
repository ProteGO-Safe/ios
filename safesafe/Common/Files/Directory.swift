//
//  Directory.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 28/05/2020.
//

import Foundation

final class Directory {
    private enum Constants {
        static let keysDirectoryName = "DiagnosisKeys"
        static let keysTempDirectoryName = "DiagnosisKeysTemporary"
    }
    
    static func getDiagnosisKeysURL() throws -> URL {
        let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return cachesDirectory.appendingPathComponent(Constants.keysDirectoryName)
    }
    
    static func getDiagnosisKeysTempURL() throws -> URL {
        let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return cachesDirectory.appendingPathComponent(Constants.keysTempDirectoryName)
    }
    
    static func removeDiagnosisKeysTempDirectory() {
        do {
            let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let directoryURL = cachesDirectory.appendingPathComponent(Constants.keysTempDirectoryName)
            try FileManager.default.removeItem(atPath: directoryURL.path)
        } catch { console(error, type: .error) }
    }
}
