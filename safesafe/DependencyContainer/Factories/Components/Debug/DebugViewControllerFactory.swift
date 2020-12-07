//
//  DebugViewControllerFactory.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 18/08/2020.
//

import Foundation

protocol DebugViewControllerFactory {
    func makeDebugViewController(closeCallback: @escaping () -> Void) -> DebugViewController
}

extension DependencyContainer: DebugViewControllerFactory {
    func makeDebugViewController(closeCallback: @escaping () -> Void) -> DebugViewController {
        let viewModel = DebugViewModel(
            districtService: districtsService,
            localStorage: realmLocalStorage)
        
        viewModel.onSimulateExposureRiskChange { [weak self] in
            if #available(iOS 13.5, *) {
                self?.jsBridge.debugSendExposureList()
            }
        }
        
        let viewController = DebugViewController(viewModel: viewModel)
        viewController.closeCallback = closeCallback
        
        return viewController
    }
}
