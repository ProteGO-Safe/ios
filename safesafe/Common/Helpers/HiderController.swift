//
//  HiderController.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 06/06/2020.
//

import UIKit

final class HiderController {
    
    private enum Constants {
        static let hiderStoryboard = "Hider"
        static let windowLevel: UIWindow.Level = .alert + 1
    }
    
    static let shared = HiderController()
    
    private var privacyProtectionWindow: UIWindow?
    private var hiderViewController: UIViewController {
        return UIStoryboard(name: Constants.hiderStoryboard, bundle: nil).instantiateViewController(withIdentifier: HiderViewController.identifier)
    }
    
    private init() {}
    
    @available(iOS 13.0, *)
    func show(windowScene: UIWindowScene?) {
        guard let windowScene = windowScene else {
            return
        }
        privacyProtectionWindow = UIWindow(windowScene: windowScene)
        setup()
    }
    
    func show() {
        privacyProtectionWindow = UIWindow(frame: UIScreen.main.bounds)
        setup()
    }
    
    func hide() {
        privacyProtectionWindow?.isHidden = true
        privacyProtectionWindow = nil
    }
    
    private func setup() {
        privacyProtectionWindow?.rootViewController = hiderViewController
        privacyProtectionWindow?.windowLevel = Constants.windowLevel
        privacyProtectionWindow?.makeKeyAndVisible()
    }
}
