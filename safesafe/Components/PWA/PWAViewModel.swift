//
//  PWAViewModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import WebKit.WKUserContentController
import WebKit.WKNavigation

enum LoadScope {
    case offline
    case online
}

protocol PWAViewModelDelegate: class {
    func load(url: URL, scope: LoadScope)
    func reload()
    func configureWebKit(controler: WKUserContentController, completion: (WKWebView) -> Void)
}

final class PWAViewModel: ViewModelType {
    
    // MARK: - Constants
    
    private enum Constants {
        static var pwaMigrationVersion = 1
        static var pwaLocalDirectoryName = "pwa"
        static var pwaLocalIndexName = "index.html"
        static var pwaLocalDirectoryURL = Bundle.main.bundleURL.appendingPathComponent(Self.pwaLocalDirectoryName)
        static var pwaLocalURL = Self.pwaLocalDirectoryURL.appendingPathComponent(Self.pwaLocalIndexName)
    }
    
    // MARK: - Properties
    
    private let jsBridge: JSBridge
    private let migrationManager: MigrationProtocol
    weak var delegate: PWAViewModelDelegate?
    var debugTapClosure: (() -> Void)?
    
    // MARK: - Life Cycle
    
    init(with jsBridge: JSBridge, migrationManager: MigrationProtocol = LocalStorageMigration()) {
        self.jsBridge = jsBridge
        self.migrationManager = migrationManager
    }
    
    /// Manage custom actions for schemes defined in  URLAction
    /// - Parameter url: WebKit navigation URL
    func manageNativeActions(with url: URL?) -> Bool {
        guard
            let url = url,
            let scheme = url.scheme,
            let action = URLAction(rawValue: scheme)
        else { return false }
        
        action.call(url: url)
        
        return true
    }
    
    
    /// Open url in external browser (safari) if url host is not from PWA domain
    /// defined in Config.plist
    /// - Parameter url: WebKit navigation URL
    func openExternallyIfNeeded(url: URL?) -> Bool {
        guard let url = url, !url.isHostEqual(to: Constants.pwaLocalDirectoryURL) else {
            return false
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        return true
    }
     
}

// VC Life Cycle
extension PWAViewModel {
    func onViewWillAppear(layoutFinished: Bool) {
        guard layoutFinished else {
            return
        }

        migrationManager.migrate { result in
             delegate?.load(url: Constants.pwaLocalURL, scope: .offline)
        }
    }
    
    func onViewDidLoad(setupFinished: Bool) {
        if setupFinished {
            delegate?.configureWebKit(controler: jsBridge.contentController) { webKitView in
                jsBridge.register(webView: webKitView)
            }
        }
    }
}

extension StoredDefaults.Key {
    static let pwaMigration = StoredDefaults.Key("pwaMigrationKey")
}

// Debug
extension PWAViewModel {
    
    func debugTapped(_ closure: @escaping (() -> Void)) {
        debugTapClosure = closure
    }
    
    @objc
    func debugButtonTapped(sender: UIButton) {
        debugTapClosure?()
    }
}
