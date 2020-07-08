//
//  AlertAction.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 01/07/2020.
//

import Foundation

enum AlertAction {
    case cancel
    case retry
    
    var title: String {
        switch self {
        case .cancel:
            return "Anuluj"
        case .retry:
            return "Ponów"
        }
    }
}
