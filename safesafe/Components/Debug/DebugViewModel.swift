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
    case uploadPayloadsShare
    case uploadPayloadsPreview
}

protocol DebugViewModelDelegate: class {
    func sharePayloads(fileURL: URL)
}

final class DebugViewModel: ViewModelType {
    weak var delegate: DebugViewModelDelegate?
    
    var numberOfPayloads: Int {
        do {
            let dirContent = try FileManager.default.contentsOfDirectory(atPath: try Directory.uploadedPayloads().path)
            return dirContent.count
        } catch {
            console(error, type: .error)
        }
        return .zero
    }
    
    func manage(debugAction: DebugAction) {
        switch debugAction {
        case .uploadPayloadsShare:
            guard let url = try? File.uploadedPayloadsZIP() else { return }
            delegate?.sharePayloads(fileURL: url)
        default: ()
        }
    }
    
}
