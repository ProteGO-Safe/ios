//
//  Clear.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/05/2020.
//

import Foundation
import FirebaseAuth
import PromiseKit

final class ClearData {
    
    typealias Executable = () -> (Promise<Void>)
    
    private enum Version: Int, CaseIterable, Comparable {
        case initial = 0
        case v1
    
        init(versionNumber: Int?) {
            guard let versionNumber = versionNumber, let version = Version(rawValue: versionNumber)  else {
                self = Version.initial
                return
            }
            
            self = version
        }
        
        static func < (lhs: ClearData.Version, rhs: ClearData.Version) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    private enum Cosntants {
        static let currentVersion: Version = .v1
    }
    
    private var executions: [Version: [Executable]] = [:]
    
    init() {
        prepare()
    }
    
    func clear() {
        let storedVersion: Int? = StoredDefaults.standard.get(key: .clearLocalData)
        let lastVersion: Version = Version(versionNumber: storedVersion)
        let range = lastVersion..<Cosntants.currentVersion
        
        let promises = Version.allCases
            .filter { range.contains($0) }
            .compactMap { executions[$0] }
            .flatMap { $0 }
            .map { $0() }
        
        guard !promises.isEmpty else { return }
        
        when(resolved: promises)
            .done { results in
                let errors = results.compactMap { result -> Error? in
                    switch result {
                    case .fulfilled:
                        return nil
                    case let .rejected(error):
                        return error
                    }
                }
                if errors.isEmpty {
                    StoredDefaults.standard.set(value: Cosntants.currentVersion.rawValue, key: .clearLocalData)
                } else {
                    console(errors, type: .error)
                }
        }
        
    }
    
    private func prepare()  {
        executions[.v1] = [deleteTracerData(), deleteUserDefaults(), deleteFirebaseUser()]
    }
}

// Version: 1
//
extension ClearData {
    private func deleteFirebaseUser() -> Executable {
        return {
            Promise { seal in
                Auth.auth().currentUser?.delete { error in
                    if let error = error {
                        seal.reject(error)
                    } else {
                        seal.fulfill(())
                    }
                }
            }
        }
    }
    
    private func deleteTracerData() -> Executable {
        return {
            Promise { seal in
                let prefix = "tracer"
                let fileManager = FileManager.default
                do {
                    let applicationSupport = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let directoryContent = try fileManager.contentsOfDirectory(atPath: applicationSupport.path)
                    for item in directoryContent {
                        if item.lowercased().contains(prefix) {
                            try fileManager.removeItem(at: applicationSupport.appendingPathComponent(item))
                        }
                    }
                    seal.fulfill(())
                } catch {
                    seal.reject(error)
                }
            }
        }
    }
    
    private func deleteUserDefaults() -> Executable {
        return {
            Promise { seal in
                let keys = ["BROADCAST_MSG", "BROAD_MSG_ARRAY", "ADVT_DATA", "ADVT_EXPIRY"]
                keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
                seal.fulfill(())
            }
        }
    }
}

extension StoredDefaults.Key {
    static let clearLocalData = StoredDefaults.Key("clearLocalData")
}
