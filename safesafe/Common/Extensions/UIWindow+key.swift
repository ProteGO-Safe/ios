//
//  UIWindow+key.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 30/06/2020.
//

import UIKit

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
