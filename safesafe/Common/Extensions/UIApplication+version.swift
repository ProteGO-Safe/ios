//
//  UIApplication+version.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 28/07/2020.
//
import UIKit

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

