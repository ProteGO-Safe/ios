import Foundation

struct FilesCoordinator: FilesCoordinatorType {
    var realmFilePath: URL {
        self.createURLIfNotExist(url: appSupportRoot)
        return appSupportRoot.appendingPathComponent("protego.realm", isDirectory: false)
    }

    private var appSupportRoot: URL {
        if let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            self.createURLIfNotExist(url: appSupportDir)
            return appSupportDir
        }

        logger.error("Can't create app support dir")
        return dummyURL
    }

    private let fileManager: FileManager

    private let dummyURL = URL(fileURLWithPath: "")

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    private func createURLIfNotExist(url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try self.fileManager.createDirectory(at: url,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
            } catch {
                logger.error("Can't create destination folder. Error: \(error)")
            }
        }
    }
}
