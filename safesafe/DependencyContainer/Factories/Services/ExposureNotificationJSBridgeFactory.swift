//
//  ExposureNotificationJSBridgeFactory.swift
//  safesafe
//

import UIKit

@available(iOS 13.5, *)
protocol ExposureNotificationJSBridgeFactory {
    
    func makeExposureNotificationJSBridge(with viewController: UIViewController) -> ExposureNotificationJSProtocol
    
}

@available(iOS 13.5, *)
extension DependencyContainer: ExposureNotificationJSBridgeFactory {
    
    func makeExposureNotificationJSBridge(with viewController: UIViewController) -> ExposureNotificationJSProtocol {
        return ExposureNotificationJSBridge(
            exposureService: exposureService,
            exposureSummaryService: exposureSummaryService,
            exposureStatus: exposureService,
            viewController: viewController
        )
    }
    
}
