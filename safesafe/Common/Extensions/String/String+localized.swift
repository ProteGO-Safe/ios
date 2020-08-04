//
//  String+localized.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 04/08/2020.
//

import Foundation

extension String {
    
    private enum Constants {
        static let bundleNotFoundPrefix = "BNF_"
        static let localizedFileExtension = "lproj"
    }
    
    /// path or bundle not found -> BNF_{languageCode}_{self}
    /// translation not found -> {languageCode}_{self}
    /// string is not localized (missing localized()) -> {self}
    func localized(_ languageCode: String = LanguageController.default.language, comment: String = .empty) -> String {
        guard
            let path = Bundle.main.path(forResource: languageCodeMapper(languageCode), ofType: "lproj"),
            let bundle = Bundle(path: path)
            else { return "\(Constants.bundleNotFoundPrefix)\(languageCode)_\(self)" }
        
        let localized = NSLocalizedString(self, tableName: nil, bundle: bundle, value: .empty, comment: comment)
        if localized == self {
            return "\(languageCode)_\(self)"
        }
        
        return localized
    }

    
    /// Xcode manage some languages adding country suffix to .lproj folder name. Until PWA (JS) will return only language code in ISO 639-1
    /// we need to map this code to valid folder name. If map doesn't exists, we return only languge code passed as input param
    /// - Parameter code: language code in ISO 639-1
    /// - Returns: mapped name (combination of `language-COUNTRY`
    private func languageCodeMapper(_ code: String) -> String {
        let map: [String: String] = ["uk": "uk-UA"]
        guard let result = map[code.lowercased()] else { return code }
        
        return result
    }
}
