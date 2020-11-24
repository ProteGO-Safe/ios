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
        let viewModel = DebugViewModel(
            districtService: districtsService,
            localStorage: realmLocalStorage)
        
        viewModel.onSimulateExposureRiskChange { [weak self] in
            if #available(iOS 13.5, *) {
                self?.jsBridge.debugSendExposureList()
            }
        }
        return DebugViewController(viewModel: viewModel)
    }
}
