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
        static let uploadedPayloads = "UploadedPayloads"
        static let logs = "Logs"
    }
    
    static func webkitLocalStorage() throws -> URL {
        let libraryDirectory = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return libraryDirectory.appendingPathComponent("WebKit")
            .appendingPathComponent("WebsiteData")
            .appendingPathComponent("LocalStorage")
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
    
    static func logs() throws -> URL {
        let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destinationURL = cachesDirectory.appendingPathComponent(Constants.logs)
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            console(error, type: .warning)
        }
        return destinationURL
    }
    
    static func uploadedPayloads() throws -> URL {
        let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destinationURL = cachesDirectory.appendingPathComponent(Constants.uploadedPayloads)
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            console(error, type: .warning)
        }
        return destinationURL
    }
    
    static func uploadedPayloadsTemp() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let destinationURL = tempDir.appendingPathComponent(Constants.uploadedPayloads)
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            console(error, type: .warning)
        }
        return destinationURL
    }
}
