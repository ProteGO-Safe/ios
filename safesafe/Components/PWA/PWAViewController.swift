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
import PromiseKit

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
    func load(url: URL, scope: LoadScope) {
        if case .offline = scope {
            webKitView?.loadFileURL(url, allowingReadAccessTo: url)
        }
        
        webKitView?.load(URLRequest(url: url))
    }
    
    func configureWebKit(controler: WKUserContentController, completion: (WKWebView) -> Void) {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controler
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
    
    func checkStorage() {
        webKitView?.evaluateJavaScript("localStorage.getItem('persist:root');") { [weak self] result, error in
            guard let data = result as? String else {
                self?.viewModel.webViewStorage(storage: .failure(InternalError.invalidDataType))
                return
            }
            console(self?.webKitView?.url)
            console(data)
        }
    }
    
    func fetchStorage() {
        webKitView?.evaluateJavaScript("localStorage.getItem('persist:root');") { [weak self] result, error in
            guard let data = result as? String else {
                self?.viewModel.webViewStorage(storage: .failure(InternalError.invalidDataType))
                return
            }
        
            if let error = error {
                self?.viewModel.webViewStorage(storage: .failure(error))
            } else {
                self?.viewModel.webViewStorage(storage: .success(data))
            }
        }
    }
    
    func setStorage(data: String) {
        WebCacheCleaner.clean()
            .then {
                after(seconds: 2)
        }
        .done {
            
            let method = "localStorage.setItem('persist:root','\(data)');"
            self.webKitView?.evaluateJavaScript(method) { [weak self] result, error in
                if let error = error {
                    console(error, type: .error)
                }
                self?.webKitView?.reload()
            }
        }
        .catch {
            console($0, type: .error)
        }
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.webViewFinishedLoad(navigation)
    }
    
}
