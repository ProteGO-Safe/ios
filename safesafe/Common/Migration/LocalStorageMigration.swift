//
//  LocalStorageMigration.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 17/06/2020.
//

import Foundation

protocol MigrationProtocol {
    func migrate(done: (Result<Bool, Error>) -> ())
}


final class LocalStorageMigration: MigrationProtocol {
    
    private enum Constants {
        // The order of this names matters, it should be `newest` -> `oldest`
        static let previousStorages = ["v4.safesafe.app", "safesafe.app"]
        static let offlineStoragePrefix = "file__0"
        static let storageSuffixes = ["localstorage-wal", "localstorage-shm", "localstorage"]
    }
        
    func migrate(done: (Result<Bool, Error>) -> ()) {
        do {
            var oldStorageFiles: [String] = []
            for oldStorageName in Constants.previousStorages {
                oldStorageFiles = try files(contains: oldStorageName)
                if !oldStorageFiles.isEmpty { break }
            }
            
            guard !oldStorageFiles.isEmpty else {
                done(.success(false))
                return
            }
            
            try deleteFiles(prefix: Constants.offlineStoragePrefix)
            try renameFiles(from: oldStorageFiles, to: Constants.offlineStoragePrefix)
            
            done(.success(true))
            
        } catch {
            console(error, type: .error)
            done(.failure(error))
        }
    }
    
    private func directoryContent() throws -> [String] {
        let directoryURL = try Directory.webkitLocalStorage()
        return try FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
    }
    
    private func deleteFiles(prefix: String) throws {
        for file in try directoryContent() {
            if file.hasPrefix(prefix) {
                let fileURL = try Directory.webkitLocalStorage().appendingPathComponent(file)
                try FileManager.default.removeItem(at: fileURL)
            }
        }
    }
    
    private func files(contains: String) throws -> [String] {
        return try directoryContent().filter { $0.contains(contains) }
    }
    
    private func files(withPrefix: String) throws -> [String] {
        return try directoryContent().filter { $0.hasPrefix(withPrefix) }
    }
    
    private func renameFiles(from fileNames: [String], to filePrefix: String) throws {
        let directoryURL = try Directory.webkitLocalStorage()
        let filesURL = fileNames.compactMap { file -> (original: URL, new: URL)? in
            if let suffix = file.hasSuffix(in: Constants.storageSuffixes) {
                return (directoryURL.appendingPathComponent(file), directoryURL.appendingPathComponent("\(filePrefix).\(suffix)"))
            }
            return nil
        }
        
        for filesPair in filesURL {
            try FileManager.default.moveItem(at: filesPair.original, to: filesPair.new)
        }
    }
}

extension String {
    func hasSuffix(in array: [String]) -> String? {
        var result: String?
        for suffix in array {
            if self.hasSuffix(suffix) {
                result = suffix
                break
            }
        }
        return result
    }
}
