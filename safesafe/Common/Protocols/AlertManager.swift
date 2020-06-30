//
//  AlertManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 30/06/2020.
//

import UIKit

enum AlertType {
    case noInternet
    case uploadGeneral
}

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

protocol AlertManager {
    var viewController: UIViewController? { get }
    func register(viewController: UIViewController)
    func show(type: AlertType, result: @escaping (AlertAction) -> ())
}

extension AlertManager {
    func register(viewController: UIViewController) {}
}
