//
//  PWAViewController.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

final class PWAViewController: ViewController<PWAViewModel> {
    
    private var webKitView: WKWebView?
    
    override func start() {
        viewModel.delegate = self
    }
    
    override func setup() {
        setupWebKit()
    }
    
    override func layout() {
        webKitView?.snp.makeConstraints({ maker in
            maker.edges.equalToSuperview()
        })
    }
    
    private func setupWebKit() {
        let configuration = WKWebViewConfiguration()
        let webKitView = WKWebView(frame: .zero, configuration: configuration)
        add(subview: webKitView)
        
        self.webKitView = webKitView
    }
}

extension PWAViewController: PWAViewModelDelegate {
    func load(url: URL) {
        webKitView?.load(URLRequest(url: url))
    }
}
