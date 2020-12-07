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
        viewModel.registerDebug { [weak self, viewController, viewModel] in
            guard let self = self else { return }
            
            viewController.present(self.makeDebugViewController(closeCallback: viewModel.didCloseDebugView), animated: true)
        }
        return viewController
    }
    
}
