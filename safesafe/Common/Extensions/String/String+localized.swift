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
        static var localDirectoryName = "translations"
    }
    
    /// path or bundle not found -> BNF_{languageCode}_{self}
    /// translation not found -> {languageCode}_{self}
    /// string is not localized (missing localized()) -> {self}
    func localized(_ languageCode: String = LanguageController.default.language, comment: String = .empty) -> String {

        guard let path = Bundle.main.path(forResource: Constants.localDirectoryName, ofType: nil),
            let bundle = Bundle(path: path)
            else { return "\(Constants.bundleNotFoundPrefix)\(languageCode)_\(self)" }
        
        let localized = NSLocalizedString(self, tableName: languageCode, bundle: bundle, value: .empty, comment: comment)
        if localized == self {
            return "\(languageCode)_\(self)"
        }

        return localized
    }
}
