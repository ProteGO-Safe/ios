//
//  DiagnosisKeysDownloadService.swift
//  safesafe
//

import PromiseKit
import ZIPFoundation
import Moya
import Alamofire

protocol DiagnosisKeysDownloadServiceProtocol {
    
    func download() -> Promise<[URL]>
    func deleteFiles()
    
}


@available(iOS 13.5, *)
final class DiagnosisKeysDownloadService: DiagnosisKeysDownloadServiceProtocol {
    
    // MARK: - Properties
    
    private let remoteConfig: RemoteConfigProtocol
    private let fileManager: FileManager
    private let exposureKeysProvider: MoyaProvider<ExposureKeysTarget>
    
    // MARK: - Life Cycle
    
    init(
        with remoteConfig: RemoteConfigProtocol,
        fileManager: FileManager = FileManager.default,
        exposureKeysProvider: MoyaProvider<ExposureKeysTarget>
    ) {
        self.remoteConfig = remoteConfig
        self.fileManager = fileManager
        self.exposureKeysProvider = exposureKeysProvider
    }
    
    static func extractTimestamp(name: String) -> String? {
        let splited = name.split(separator: "-")
        guard let timestamp = splited.first else {
            return nil
        }
        
        return String(timestamp)
    }
    
    // MARK: - Diagnosis Keys

    private func downloadFiles(withNames names: [String], keysDirectoryURL: URL) -> Promise<[URL]> {
        Promise { seal in
            let dispatchGroup = DispatchGroup()
            var fileURLs = [URL]()
            var fileURLResults = [Swift.Result<[URL], Error>]()
            
            for name in names {
                dispatchGroup.enter()
                
                exposureKeysProvider.request(.download(fileName: name, destination: downloadDestination)) { result in
                    switch result {
                    case .success:
                        guard let directoryName = Self.extractTimestamp(name: name) else {
                            fileURLResults.append(.failure(InternalError.extractingDirectoryName))
                            return
                        }
                        
                        do {
                            let unzipDestinationURL = try Directory.getDiagnosisKeysURL().appendingPathComponent(directoryName)
                            let urls = try self.fileManager.contentsOfDirectory(at: unzipDestinationURL, includingPropertiesForKeys: nil)
                            fileURLResults.append(.success(urls))
                        } catch {
                            fileURLResults.append(.failure(error))
                        }
                        
                    case let .failure(error):
                        fileURLResults.append(.failure(error))
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                Directory.removeDiagnosisKeysTempDirectory()
            
                for result in fileURLResults {
                    switch result {
                    case let .success(urls):
                        fileURLs.append(contentsOf: urls)
                    case .failure: continue
                    }
                }
                
                seal.fulfill(fileURLs)
            }
        }
    }
    
    private func downloadDestination(temporaryURL: URL, response: HTTPURLResponse) -> (destinationURL: URL, options: DownloadRequest.Options) {
        guard
            let suggestedFilename = response.suggestedFilename,
            let directoryName = DiagnosisKeysDownloadService.extractTimestamp(name: suggestedFilename),
            let temporaryDirectory = try? Directory.getDiagnosisKeysTempURL(),
            (200...299).contains(response.statusCode)
        else {
            return(temporaryURL, [.removePreviousFile])
        }
        
        do {
            let unzipDestinationURL = try Directory.getDiagnosisKeysURL().appendingPathComponent(directoryName)
            
            try FileManager.default.unzipItem(at: temporaryURL, to: unzipDestinationURL)
            renameAll(directoryName, dirPath: unzipDestinationURL)
            console("Diagnosis Key files saved to: \(unzipDestinationURL)")
            
        } catch {
            console(error, type: .error)
        }
        
        return(temporaryDirectory, [.removePreviousFile])
    }
    
    private func renameAll(_ filename: String, dirPath: URL) {
        do {
            for file in try fileManager.contentsOfDirectory(atPath: dirPath.path) {
                let originalPath = dirPath.appendingPathComponent(file)
                let newPath = dirPath.appendingPathComponent("\(filename).\(originalPath.pathExtension)")
                try fileManager.moveItem(at: originalPath, to: newPath)
            }
        } catch {
            console(error, type: .error)
        }
    }
    
    private func filter(keyFileNames: [Substring]) -> [String] {
        let downloadTimestamp = StoredDefaults.standard.get(key: .diagnosisKeysDownloadTimestamp) ?? 0
        
        var names = keyFileNames
            .map { String($0.replacingOccurrences(of: "/", with: "")) }
            .filter { name -> Bool in
            guard
                let fileName = Self.extractTimestamp(name: name),
                let keyTimestamp = Int(fileName)
            else { return false }
            
            return keyTimestamp > downloadTimestamp
        }
        
        do {
            let savedFileNames = try fileManager.contentsOfDirectory(
                at: try Directory.getDiagnosisKeysURL(),
                includingPropertiesForKeys: nil
            )
            .map(\.lastPathComponent)
            
            names = Array(Set(names).subtracting(savedFileNames))
        } catch {
            console(error)
        }
        
        return names
    }
    
    func download() -> Promise<[URL]> {
        Promise { seal in
            exposureKeysProvider.request(.get) { [weak self] result in
                guard let self = self else {
                    seal.reject(InternalError.deinitialized)
                    return
                }
                
                switch result {
                case let .success(response):
                    let filesList = String(bytes: response.data, encoding: .utf8)?.split(separator: "\n") ?? []
                    
                    guard let keysDirectoryURL = try? Directory.getDiagnosisKeysURL() else {
                        seal.reject(InternalError.locatingDictionary)
                        return
                    }
                    
                    do {
                        try self.fileManager.createDirectory(at: keysDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        seal.reject(error)
                        return
                    }
                    
                    let itemNames = self.filter(keyFileNames: filesList)
                    guard !itemNames.isEmpty else {
                        seal.reject(PMKError.cancelled)
                        return
                    }
                    
                    self.downloadFiles(withNames: itemNames, keysDirectoryURL: keysDirectoryURL).done { urls in
                        let timestamps =  urls.map { $0.lastPathComponent }
                            .compactMap { $0.split(separator: ".").first }
                            .map { String($0) }
                            .compactMap(Int.init)
                            .sorted()
                        
                        if let lastTimestamp = timestamps.last {
                            StoredDefaults.standard.set(value: lastTimestamp, key: .diagnosisKeysDownloadTimestamp)
                        }
    
                        seal.fulfill(urls)
                    }.catch {
                        seal.reject($0)
                    }
                    
                case let .failure(error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func deleteFiles() {
        do {
            try fileManager.removeItem(at: try Directory.getDiagnosisKeysURL())
        } catch {
            console(error)
        }
    }
}

extension StoredDefaults.Key {
    static let diagnosisKeysDownloadTimestamp = StoredDefaults.Key("diagnosisKeysDownloadTimestamp")
}
