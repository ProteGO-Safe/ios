//
//  DebugViewControllerFactory.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 18/08/2020.
//

import Foundation

protocol DebugViewControllerFactory {
    func makeDebugViewController() -> DebugViewController
}

extension DependencyContainer: DebugViewControllerFactory {
    func makeDebugViewController() -> DebugViewController {
        let viewModel = DebugViewModel()
        return DebugViewController(viewModel: viewModel)
    }
}
