//
//  File.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 18/08/2020.
//

import Foundation
import ZIPFoundation

final class File {
    
    static let logFileName = "log.txt"
    
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
    
    @available(iOS 13.0, *)
    static func append(data: Data, to fileName: String, in directory: URL) {
        let fileURL = directory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
                try fileHandle.seekToEnd()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch { /* Can't print this error to console(...) because it will loop forever */ }
        } else {
            do {
                try data.write(to: fileURL, options: .atomicWrite)
            } catch { /* Can't print this error to console(...) because it will loop forever */ }
        }
    }
}

extension File {
    static func logFileURL() throws -> URL? {
        do {
            return try Directory.logs().appendingPathComponent(logFileName)
        } catch { /* Can't print this error to console(...) because it will loop forever */ }
        
        return nil
    }
    
    @available(iOS 13.0, *)
    static func logToFile(_ message: String) {
        guard let data = message.appending("\n").data(using: .utf8) else { return }
        do {
            append(data: data, to: logFileName, in: try Directory.logs())
        } catch { /* Can't print this error to console(...) because it will loop forever */ }
    }
    
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
