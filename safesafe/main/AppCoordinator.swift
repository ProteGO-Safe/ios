//
//  AppCoordinator.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit

final class AppCoordinator: CoordinatorType {
    
    private let appManager = AppManager.instance
    private let window: UIWindow
    
    required init() {
        fatalError("Not implemented")
    }
    
    init?(appWindow: UIWindow?) {
        guard let window = appWindow else {
            fatalError("Window doesn't exists")
        }
        
        self.window = window
    }
    
    func start() {
        window.backgroundColor = .white
        window.rootViewController = pwa()
        window.makeKeyAndVisible()
    }
    
    private func pwa() -> UIViewController {
        let viewModel = PWAViewModel()
        let navigationController = NavigationControler(rootViewController: PWAViewController(viewModel: viewModel))
        return navigationController
    }
}
