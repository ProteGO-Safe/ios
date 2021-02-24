//
//  FileStorage.swift
//  safesafe
//
//  Created by Namedix on 19/02/2021.
//

import Foundation

protocol FileStorageType: AnyObject {
    func write(to fileName: FileStorage.Key, content: Data) -> Result<Void, FileStorage.FileError>
    func read(from fileName: FileStorage.Key) -> Result<Data, FileStorage.FileError>
}

final class FileStorage: FileStorageType {
    enum Key: String {
        case timestamps
        case dashboard
        case details
        case districts
    }

    enum FileError: Error {
        case wrongDirectory
        case write(error: Error)
        case read(error: Error)
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }

    func write(to fileName: Key, content: Data) -> Result<Void, FileError> {
        switch getFileUrl(for: fileName) {
        case .success(let fileUrl):
            do {
                try content.write(to: fileUrl, options: .noFileProtection)
                return .success(())
            } catch let error {
                return .failure(.write(error: error))
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    func read(from fileName: Key) -> Result<Data, FileError> {
        switch getFileUrl(for: fileName) {
        case .success(let url):
            do {
                let content = try Data(contentsOf: url)
                return .success(content)
            } catch let error {
                return .failure(.read(error: error))
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    private func getFileUrl(for key: Key) -> Result<URL, FileError> {
        let fileName = key.rawValue
        guard let documentDirectoryURL = try? fileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
        ) else { return .failure(FileError.wrongDirectory) }

        return .success(
            documentDirectoryURL
                .appendingPathComponent(fileName)
                .appendingPathExtension("json")
        )
    }
}
