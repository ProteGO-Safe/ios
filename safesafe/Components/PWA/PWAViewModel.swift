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
    func configureWebKit(controler: WKUserContentController, completion: (WKWebView) -> Void)
    func fetchStorage()
    func setStorage(data: String)
    func checkStorage()
}

final class PWAViewModel: ViewModelType {
    
    // MARK: - Constants
    
    private enum Constants {
        static var pwaMigrationVersion = 1
        static var pwaV3OnlineURL: URL = .build(scheme: "https", host: "safesafe.app")!
        static var pwaV4OnlineURL: URL = .build(scheme: "https", host: "v4.safesafe.app")!
        static var pwaLocalDirectoryName = "pwa"
        static var pwaLocalIndexName = "index.html"
        static var pwaLocalDirectoryURL = Bundle.main.bundleURL.appendingPathComponent(Self.pwaLocalDirectoryName)
        static var pwaLocalURL = Self.pwaLocalDirectoryURL.appendingPathComponent(Self.pwaLocalIndexName)
        static var pwaURL: URL = .build(scheme: ConfigManager.default.pwaScheme, host:ConfigManager.default.pwaHost)!
    }
    
    // MARK: - Properties
    
    private let jsBridge: JSBridge
    private var localStorageData: String?
    private var openExternallyEnabled = false
    weak var delegate: PWAViewModelDelegate?
    
    // MARK: - Life Cycle
    
    init(with jsBridge: JSBridge) {
        self.jsBridge = jsBridge
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
        guard let url = url, !url.isHostEqual(to: Constants.pwaLocalDirectoryURL), openExternallyEnabled else {
            return false
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        return true
    }
    
    func webViewFinishedLoad(_ navigation: WKNavigation) {
        if let pwaMigrationVersion: Int? = StoredDefaults.standard.get(key: .pwaMigration), pwaMigrationVersion == nil, localStorageData == nil {
            // do PWA migration
            delegate?.fetchStorage()
        } else if let data = localStorageData {
            // got data, let's migrate!
            delegate?.setStorage(data: data)
            localStorageData = nil
            StoredDefaults.standard.set(value: Constants.pwaMigrationVersion, key: .pwaMigration)
        } else {
            delegate?.checkStorage()
        }
    }
    
    func webViewStorage(storage: Result<String, Error>) {
        if case .success(let data) = storage {
            localStorageData = data
        }
        openExternallyEnabled = true
        delegate?.load(url: Constants.pwaLocalURL, scope: .offline)
    }
    
    private func isPWAV3() -> Bool {
        return UserDefaults.standard.value(forKey: "BROADCAST_MSG") != nil ||
            UserDefaults.standard.value(forKey: "BROAD_MSG_ARRAY") != nil ||
            UserDefaults.standard.value(forKey: "ADVT_DATA") != nil ||
            UserDefaults.standard.value(forKey: "ADVT_EXPIRY") != nil
    }
}

// VC Life Cycle
extension PWAViewModel {
    func onViewWillAppear(layoutFinished: Bool) {
        guard layoutFinished else {
            return
        }
        
        if let pwaMigrationVersion: Int? = StoredDefaults.standard.get(key: .pwaMigration), pwaMigrationVersion != nil {
            openExternallyEnabled = true
            delegate?.load(url: Constants.pwaLocalURL, scope: .offline)
        } else {
            // Load correct pwa URL
            if isPWAV3() {
                delegate?.load(url: Constants.pwaV3OnlineURL, scope: .online)
            } else {
                delegate?.load(url: Constants.pwaV4OnlineURL, scope: .online)
            }
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
