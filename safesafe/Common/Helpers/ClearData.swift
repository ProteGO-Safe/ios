//
//  Clear.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/05/2020.
//

import Foundation
import FirebaseAuth

final class ClearData {
    
    func clear() {
        deleteTracerData()
        deleteUserDefaults()
        Auth.auth().currentUser?.delete { _ in}
    }
    
    private func deleteTracerData() {
        let preffix = "tracer"
        let fileManager = FileManager.default
        do {
            let applicationSupport = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let directoryContent = try fileManager.contentsOfDirectory(atPath: applicationSupport.path)
            for item in directoryContent {
                if item.lowercased().contains(preffix) {
                    try fileManager.removeItem(at: applicationSupport.appendingPathComponent(item))
                }
            }
        } catch {
            console(error, type: .error)
        }
    }
    
    private func deleteUserDefaults() {
        let keys = ["BROADCAST_MSG", "BROAD_MSG_ARRAY", "ADVT_DATA", "ADVT_EXPIRY"]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}
