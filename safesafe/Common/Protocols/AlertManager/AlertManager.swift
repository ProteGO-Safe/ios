//
//  AlertManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 30/06/2020.
//

import UIKit

protocol AlertManager {
    var viewController: UIViewController? { get }
    func register(viewController: UIViewController)
    func show(type: AlertType, result: @escaping (AlertAction) -> ())
}

extension AlertManager {
    func register(viewController: UIViewController) {}
}
