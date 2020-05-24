//
//  ExposureNotificationJSBridge.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 17/05/2020.
//

import Foundation
import PromiseKit
import ExposureNotification

protocol ExposureNotificationJSProtocol: class {
    
    func enableService(enable: Bool) -> Promise<Void>
    func getExposureSummary() -> Promise<ExposureInfoSummary>
    
}

@available(iOS 13.5, *)
final class ExposureNotificationJSBridge: ExposureNotificationJSProtocol {
    
    // MARK: - Properties
    
    private let exposureService: ExposureServiceProtocol
    private let exposureSummaryService: ExposureSummaryServiceProtocol
    
    private weak var viewController: UIViewController?
    
    // MARK: - Life Cycle

    init(
        exposureService: ExposureServiceProtocol,
        exposureSummaryService: ExposureSummaryServiceProtocol,
        viewController: UIViewController
    ) {
        self.exposureService = exposureService
        self.exposureSummaryService = exposureSummaryService
        self.viewController = viewController
    }
    
    // MARK: - Public methods
    
    func enableService(enable: Bool) -> Promise<Void> {
        (enable ? turnOnService() : exposureService.setExposureNotificationEnabled(false))
            .recover { error -> Guarantee<()> in
                guard let error = error as? ENError else {
                    return .value
                }
                
                switch error.code {
                case .notEnabled:
                    console("ENA not enabled", type: .warning)
                case .restricted:
                    console("ENA retrictedf", type: .warning)
                case .invalidated:
                    console("ENA invalidated", type: .warning)
                case .notAuthorized:
                    console("ENA Not authorized")
                default:
                    console("ENA Error code")
                }
                
                return .value
        }
    }
    
    func getExposureSummary() -> Promise<ExposureInfoSummary> {
        Promise { seal in
            firstly {
                when(fulfilled: [exposureService.detectExposures()])
            }.done { _ in
                let daySummaries = self.exposureSummaryService.getExposureSummary()
                seal.fulfill(ExposureInfoSummary(exposureNotificationStatistics: daySummaries))
            }.catch {
                seal.reject($0)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func turnOnService() -> Promise<Void> {
        return  exposureService.setExposureNotificationEnabled(true)
            .recover { [viewController] error -> Promise<Void> in
                if let error = error as? ENError {
                    switch error.code {
                    case .notAuthorized:
                        guard let viewController = viewController else { return .init(error: InternalError.nilValue) }
                        return Permissions.instance.choiceAlert(for: .exposureNotification, on: viewController)
                            .then { action -> Promise<Void> in
                                guard action == .skip else {  return .init(error: PMKError.cancelled) }
                                return .value
                        }
                    default:
                        return .value
                    }
                } else {
                    return .value
                }
        }
    }
}
