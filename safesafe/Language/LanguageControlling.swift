//
//  LanguageControlling.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 04/08/2020.
//

import Foundation

protocol LanguageControlling {
    var language: String { get }
    func update(languageCode: String)
}
