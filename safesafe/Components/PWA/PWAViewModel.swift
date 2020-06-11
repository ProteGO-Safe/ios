//
//  PWAViewModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import WebKit.WKUserContentController

protocol PWAViewModelDelegate: class {
    func load(url: URL)
    func configureWebKit(controler: WKUserContentController, completion: (WKWebView) -> Void)
}

final class PWAViewModel: ViewModelType {
    
    // MARK: - Constants
    
    private enum Constants {
        static var pwaLocalDirectoryName = "pwa"
        static var pwaLocalIndexName = "index.html"
        static var pwaLocalDirectoryURL = Bundle.main.bundleURL.appendingPathComponent(Self.pwaLocalDirectoryName)
        static var pwaLocalURL = Self.pwaLocalDirectoryURL.appendingPathComponent(Self.pwaLocalIndexName)
        static var pwaURL: URL = .build(scheme: ConfigManager.default.pwaScheme, host:ConfigManager.default.pwaHost)!
    }
    
    // MARK: - Properties
    
    private let jsBridge: JSBridge
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
        
        delegate?.load(url: Constants.pwaLocalURL)
    }
    
    func onViewDidLoad(setupFinished: Bool) {
        if setupFinished {
            delegate?.configureWebKit(controler: jsBridge.contentController) { webKitView in
                jsBridge.register(webView: webKitView)
            }
        }
    }
}
