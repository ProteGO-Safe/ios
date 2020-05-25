//
//  PWAViewControllerFactory.swift
//  safesafe
//

import Foundation

protocol PWAViewControllerFactory {
    func makePWAViewController() -> PWAViewController
}

extension DependencyContainer: PWAViewControllerFactory {
    
    func makePWAViewController() -> PWAViewController {
        let viewModel = PWAViewModel(with: jsBridge)
        return PWAViewController(viewModel: viewModel)
    }
    
}
