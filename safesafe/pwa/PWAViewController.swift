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
    
    private enum Constants {
        static let webViewBackground = UIColor(red:0.12, green:0.32, blue:0.62, alpha:1.00)
    }
    
    private var webKitView: WKWebView?
    
    override func start() {
        viewModel.delegate = self
    }
    
    override func setup() {}
    
    override func layout() {
        webKitView?.snp.makeConstraints({ maker in
            maker.edges.equalToSuperview()
        })
    }
}

extension PWAViewController: PWAViewModelDelegate {
    func load(url: URL) {
        webKitView?.load(URLRequest(url: url))
    }
    
    func configureWebKit(controler: WKUserContentController) {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controler
        let webKitView = WKWebView(frame: .zero, configuration: configuration)
        add(subview: webKitView)
        
        self.webKitView = webKitView
    }
}
