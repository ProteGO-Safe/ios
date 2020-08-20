//
//  DebugViewModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 18/08/2020.
//

import Foundation
import ZIPFoundation

enum DebugAction {
    case none
    case uploadedPayloadsShare
    case uploadedPayloadsPreview
    case logsShare
}

protocol DebugViewModelDelegate: class {
    func sharePayloads(fileURL: URL)
    func shareLogs(fileURL: URL)
}

final class DebugViewModel: ViewModelType {
    weak var delegate: DebugViewModelDelegate?
    
    enum Texts {
        static let title = "Debug"
        static let noUploadedPayloadsTitle = "No Uploaded Payloads Yet"
        static let shareUploadedPayloadsTitle = "Share Uploaded Payloads"
        static let noLogsTitle = "Nothing logged yet"
        static let shareLogsTitle = "Share Logs"
    }
    
    var numberOfPayloads: Int {
        do {
            let dirContent = try FileManager.default.contentsOfDirectory(atPath: try Directory.uploadedPayloads().path)
            return dirContent.count
        } catch {
            console(error, type: .error)
        }
        return .zero
    }
    
    var logExists: Bool {
        do {
            let dirContent = try FileManager.default.contentsOfDirectory(atPath: try Directory.logs().path)
            return dirContent.count != .zero
        } catch {
            console(error, type: .error)
        }
        return false
    }
    
    func manage(debugAction: DebugAction) {
        switch debugAction {
        case .uploadedPayloadsShare:
            guard let url = try? File.uploadedPayloadsZIP() else { return }
            delegate?.sharePayloads(fileURL: url)
        case .logsShare:
            guard let url = try? File.logFileURL() else { return }
            delegate?.shareLogs(fileURL: url)
        default: ()
        }
    }
    
}
