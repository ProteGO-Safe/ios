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

enum LanguageController {
    private enum Constants {
        static let defaultLanguage = "pl"
    }
    
    static let `default` = Constants.defaultLanguage
    static let selected: String = StoredDefaults.standard.get(key: .selectedLanguage) ?? systemLanguage
    
    static let systemLanguage = Locale.current.languageCode ?? Constants.defaultLanguage
    
    static func update(languageCode: String) {
        let oldLanguage = selected
        
        StoredDefaults.standard.set(value: languageCode, key: .selectedLanguage)
        
        NotificationCenter.default.post(name: .languageDidChange, object: LanguageChangeModel(fromLanguage: oldLanguage, toLanguage: languageCode))
    }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name(rawValue: "languageDidChangeNotification")
}

extension StoredDefaults.Key {
    static let selectedLanguage = StoredDefaults.Key("selectedLanguage")
}
