//
//  LanguageController.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 04/08/2020.
//

import Foundation

struct LanguageChangeModel {
    let fromLanguage: String
    let toLanguage: String
}

final class LanguageController: LanguageControlling {
    
    private enum Constants {
        static let defaultLanguage = "pl"
    }
    
    static let `default` = LanguageController()
    
    private(set) var language: String = Locale.current.languageCode ?? Constants.defaultLanguage
    
    private init() {}
    
    func update(languageCode: String) {
        let currentLanguage = language
        language = languageCode
        NotificationCenter.default.post(name: .languageDidChange, object: LanguageChangeModel(fromLanguage: currentLanguage, toLanguage: languageCode))
    }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name(rawValue: "languageDidChangeNotification")
}
