//
//  DiagnosisKeysDownloadService.swift
//  safesafe
//

import FirebaseStorage
import PromiseKit
import ZIPFoundation

protocol DiagnosisKeysDownloadServiceProtocol {
    
    func download() -> Promise<[URL]>
    func deleteFiles()
    
}

@available(iOS 13.5, *)
final class DiagnosisKeysDownloadService: DiagnosisKeysDownloadServiceProtocol {
    
    // MARK: - Constants
    
    private enum Directory {
        static let keys = "DiagnosisKeys"
    }
    
    // MARK: - Properties
    
    private let remoteConfig: RemoteConfigProtocol
    private let fileManager: FileManager
    private let storage: Storage
    private let storageReference: StorageReference
    
    // MARK: - Life Cycle
    
    init(
        with remoteConfig: RemoteConfigProtocol,
        fileManager: FileManager = FileManager.default,
        storage: Storage = Storage.storage(url: ConfigManager.default.enStorageURL)
    ) {
        self.remoteConfig = remoteConfig
        self.fileManager = fileManager
        self.storage = storage
        storageReference = storage.reference()
    }
    
    // MARK: - Diagnosis Keys
    
    private func getKeysURL() throws -> URL {
        let cachesDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return cachesDirectory.appendingPathComponent(Directory.keys)
    }
    
    private func downloadFiles(withNames names: [String], keysDirectoryURL: URL) -> Promise<[URL]> {
        Promise { seal in
            let dispatchGroup = DispatchGroup()
            var fileURLs = [URL]()
            var fileURLResults = [Swift.Result<[URL], Error>]()
            
            for name in names {
                dispatchGroup.enter()
                
                let fileURL = keysDirectoryURL.appendingPathComponent(name)
                storageReference.child(name).write(toFile: fileURL) { url, error in
                    if let error = error {
                        fileURLResults.append(.failure(error))
                        dispatchGroup.leave()
                        return
                    }
                    
                    do {
                        let unzipDestinationDirectory = fileURL.deletingPathExtension().lastPathComponent
                        let unzipDestinationURL = keysDirectoryURL.appendingPathComponent(unzipDestinationDirectory)
                        
                        try self.fileManager.unzipItem(at: fileURL, to: unzipDestinationURL)
                        console("Diagnosis Key files saved to: \(unzipDestinationURL)")

                        let urls = try self.fileManager.contentsOfDirectory(at: unzipDestinationURL, includingPropertiesForKeys: nil)
                        fileURLResults.append(.success(urls))
                        dispatchGroup.leave()
                    } catch {
                        fileURLResults.append(.failure(error))
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                for result in fileURLResults {
                    switch result {
                    case let .success(urls):
                        fileURLs.append(contentsOf: urls)
                        
                    case let .failure(error):
                        seal.reject(error)
                        return
                    }
                }
                
                seal.fulfill(fileURLs)
            }
        }
    }
    
    func download() -> Promise<[URL]> {
        Promise { seal in
            storageReference.listAll { result, error in
                if let error = error {
                    seal.reject(error)
                    return
                }
                
                guard let keysDirectoryURL = try? self.getKeysURL() else {
                    seal.reject(InternalError.locatingDictionary)
                    return
                }
                
                do {
                    try self.fileManager.createDirectory(at: keysDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    seal.reject(error)
                    return
                }
                
                let downloadTimestamp = StoredDefaults.standard.get(key: .diagnosisKeysDownloadTimestamp) ?? 0
                let itemNames = result.items.filter { item -> Bool in
                    guard
                        let itemName = URL(string: item.name)?.deletingPathExtension().lastPathComponent,
                        let itemTimestamp = Int(itemName)
                    else { return false }
                    
                    return itemTimestamp > downloadTimestamp
                }
                .map(\.name)
                
                // TODO: filter already downloaded files
                
                self.downloadFiles(withNames: itemNames, keysDirectoryURL: keysDirectoryURL).done { urls in
                    StoredDefaults.standard.set(value: Int(Date().timeIntervalSince1970), key: .diagnosisKeysDownloadTimestamp)
                    seal.fulfill(urls)
                }.catch {
                    seal.reject($0)
                }
            }
        }
    }
    
    func deleteFiles() {
        do {
            try fileManager.removeItem(at: try getKeysURL())
        } catch {
            console(error)
        }
    }
    
}

extension StoredDefaults.Key {
    static let diagnosisKeysDownloadTimestamp = StoredDefaults.Key("diagnosisKeysDownloadTimestamp")
}
