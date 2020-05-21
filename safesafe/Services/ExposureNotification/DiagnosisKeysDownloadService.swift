//
//  DiagnosisKeysDownloadService.swift
//  safesafe
//

import PromiseKit

protocol DiagnosisKeysDownloadServiceProtocol {
    
    func download() -> Promise<[URL]>
    func deleteFiles() throws
    
}

@available(iOS 13.5, *)
final class DiagnosisKeysDownloadService: DiagnosisKeysDownloadServiceProtocol {
    
    // MARK: - Properties
    
    
    // MARK: - Life Cycle
    
    init() {
    }
    
    // MARK: - Diagnosis Keys
    
    func download() -> Promise<[URL]> {
        Promise { seal in
            seal.fulfill([])
        }
    }
    
    func deleteFiles() throws {
        
    }
    
}
