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
        let viewController = PWAViewController(viewModel: viewModel)
        viewModel.debugTapped { [weak self, viewController] in
            guard let self = self else { return }
            viewController.present(self.makeDebugViewController(), animated: true)
        }
        return viewController
    }
    
}
