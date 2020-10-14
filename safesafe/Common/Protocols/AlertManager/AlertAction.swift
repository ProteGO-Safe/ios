//
//  AlertAction.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 01/07/2020.
//

import Foundation

enum AlertAction {
    case cancel
    case ok
    case retry
    case settings
    
    var title: String {
        switch self {
        case .cancel:
            return "ALERT_CANCEL_BUTTON_TITLE".localized()
        case .ok:
            return "ALERT_OK_BUTTON_TITLE".localized()
        case .retry:
            return "ALERT_RETRY_BUTTON_TITLE".localized()
        case .settings:
            return "ALERT_SETTINGS_BUTTON_TITLE".localized()
        }
    }
}
