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
import TrustKit

final class PWAViewController: ViewController<PWAViewModel> {
    
    private enum Constants {
        static let color = UIColor(red:0.18, green:0.45, blue:0.85, alpha:1.00)
    }
    
    private var webKitView: WKWebView?
    
    var onAppear: (() -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onAppear?()
    }
    
    override func start() {
        viewModel.delegate = self
    }
    
    override func setup() {   }
    
    override func layout() {
        webKitView?.snp.makeConstraints({ maker in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.top.equalToSuperview()
        })
    }
}

extension PWAViewController: PWAViewModelDelegate {
    func load(url: URL) {
        webKitView?.load(URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData))
    }
    
    func configureWebKit(controler: WKUserContentController, completion: (WKWebView) -> Void) {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controler
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        let webKitView = WKWebView(frame: .zero, configuration: configuration)
        webKitView.allowsBackForwardNavigationGestures = false
        webKitView.allowsLinkPreview = false
        if #available(iOS 11.0, *) {
            webKitView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        webKitView.scrollView.bounces = false
        webKitView.navigationDelegate = self
        
        add(subview: webKitView)
        completion(webKitView)
        
        self.webKitView = webKitView
    }
}

extension PWAViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if viewModel.manageNativeActions(with: navigationAction.request.url) || viewModel.openExternallyIfNeeded(url: navigationAction.request.url) {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let validator = TrustKit.sharedInstance().pinningValidator
        validator.handle(challenge, completionHandler: completionHandler)
    }
}
