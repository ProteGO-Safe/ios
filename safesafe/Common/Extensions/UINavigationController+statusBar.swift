//
//  UINavigationController+statusBar.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
}
