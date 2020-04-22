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
    func configureWebKit(controler: WKUserContentController)
}

final class PWAViewModel: ViewModelType {
    
    weak var delegate: PWAViewModelDelegate?
    
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
    /// defined in URLConstants
    /// - Parameter url: WebKit navigation URL
    func openExternallyIfNeeded(url: URL?) -> Bool {
        guard let url = url, !url.isHostEqual(to: URLContants.pwaHost) else {
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
        
        delegate?.load(url: URLContants.pwaURL)
    }
    
    func onViewDidLoad(setupFinished: Bool) {
        if setupFinished {
            delegate?.configureWebKit(controler: JSBridge.shared.contentController)
        }
    }
}
