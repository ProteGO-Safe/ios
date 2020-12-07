//
//  ProtobufWorker.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 06/12/2020.
//

import Foundation
import SwiftProtobuf

final class ProtobufWorker {
    
    private enum Constants {
        static let minDataLengthBytes: Int = 16
    }
    
    func countAllKeys(urls: [URL]) -> Int {
        var allKeysCount: Int = .zero
        let binURLs = urls.filter { $0.pathExtension == "bin" }
        
        for url in binURLs {
            allKeysCount += countKeys(url: url)
        }
        
        return allKeysCount
    }
    
    private func countKeys(url: URL) -> Int {
        guard
            let data = try? Data(contentsOf: url),
            data.count > Constants.minDataLengthBytes,
            let decodedInfo = try? TemporaryExposureKeyExport(serializedData: data[Constants.minDataLengthBytes...])
        else {
            return .zero
        }
        
        return decodedInfo.keys.count
    }
}
