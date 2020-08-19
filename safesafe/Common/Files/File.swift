//
//  File.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 18/08/2020.
//

import Foundation
import ZIPFoundation

final class File {
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_hh-mm-ss"
        return formatter
    }
    static func save(_ data: Data?, name: String, directory: URL) {
        let fileURL = directory.appendingPathComponent(name)
        do {
            try data?.write(to: fileURL)
        } catch {
            console(error, type: .error)
        }
    }
}

extension File {
    @available(iOS 13.5, *)
    static func saveUploadedPayload(_ keysData: TemporaryExposureKeysData) {
        do {
            let encodedData = try JSONEncoder().encode(keysData)
            let fileName = "\(Self.dateFormatter.string(from: Date()))_up.txt"
            save(encodedData, name: fileName, directory: try Directory.uploadedPayloads())
        } catch {
            console(error, type: .error)
        }
    }
    
    static func uploadedPayloadsZIP() throws -> URL {
        let destinationURL = try Directory.uploadedPayloadsTemp().appendingPathComponent("\(Self.dateFormatter.string(from: Date())).zip")
        try FileManager.default.zipItem(at: try Directory.uploadedPayloads(), to: destinationURL)
        return destinationURL
    }
}
