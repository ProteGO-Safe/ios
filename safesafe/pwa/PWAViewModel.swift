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
