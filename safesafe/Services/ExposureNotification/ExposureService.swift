//
//  ExposureService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import ExposureNotification
import PromiseKit

@available(iOS 13.5, *)
protocol ExposureServiceProtocol {
    
    var isExposureNotificationAuthorized: Bool { get }
    var isExposureNotificationEnabled: Bool { get }
    
    func activateManager() -> Promise<Void>
    func setExposureNotificationEnabled(_ setEnabled: Bool) -> Promise<Void>
    func getDiagnosisKeys() -> Promise<[ENTemporaryExposureKey]>
    func detectExposures() -> Promise<Void>
    
}

@available(iOS 13.5, *)
final class ExposureService: ExposureServiceProtocol {
    
    // MARK: - Properties
    
    private let exposureManager: ENManager
    private let diagnosisKeysService: DiagnosisKeysDownloadServiceProtocol
    private let configurationService: RemoteConfigProtocol
    
    private var isCurrentlyDetectingExposures = false
    
    var isExposureNotificationAuthorized: Bool {
        ENManager.authorizationStatus == .authorized
    }
    
    var isExposureNotificationEnabled: Bool {
        exposureManager.exposureNotificationEnabled
    }
    
    // MARK: - Life Cycle
    
    init(
        exposureManager: ENManager,
        diagnosisKeysService: DiagnosisKeysDownloadServiceProtocol,
        configurationService: RemoteConfigProtocol
    ) {
        self.exposureManager = exposureManager
        self.diagnosisKeysService = diagnosisKeysService
        self.configurationService = configurationService
    }
    
    deinit {
        exposureManager.invalidate()
    }
    
    // MARK: - Public methods
    
    func activateManager() -> Promise<Void> {
        guard exposureManager.exposureNotificationStatus == .unknown else {
            return .value
        }
        
        return Promise { [weak self] seal in
            self?.exposureManager.activate { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
        }
    }
    
    func setExposureNotificationEnabled(_ setEnabled: Bool) -> Promise<Void> {
        Promise { [weak self] seal in
            self?.exposureManager.setExposureNotificationEnabled(setEnabled) { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
        }
    }
    
    func getDiagnosisKeys() -> Promise<[ENTemporaryExposureKey]> {
        Promise { [weak self] seal in
            let completion: ENGetDiagnosisKeysHandler = { exposureKeys, error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(exposureKeys ?? [])
                }
            }
            
            #if DEV || STAGE
            self?.exposureManager.getTestDiagnosisKeys(completionHandler: completion)
            #else
            self?.exposureManager.getDiagnosisKeys(completionHandler: completion)
            #endif
        }
    }
    
    func detectExposures() -> Promise<Void> {
        Promise { seal in
            firstly { when(fulfilled:
                makeExposureConfiguration(),
                diagnosisKeysService.download()
            )}
            .then { configuration, keys in
                self.detectExposures(for: configuration, keys: keys)
            }
            .done { summary in
                self.getExposureInfo(from: summary)
                    .done {
                        seal.fulfill(())
                    }
                    .catch {
                        seal.reject($0)
                    }
            }
            .catch {
                seal.reject($0)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func detectExposures(for configuration: ENExposureConfiguration, keys: [URL]) -> Promise<ENExposureDetectionSummary> {
        Promise { seal in
            exposureManager.detectExposures(configuration: configuration, diagnosisKeyURLs: keys) { summary, error in
                guard let summary = summary, error == nil else {
                    seal.reject(error!)
                    return
                }
                seal.fulfill(summary)
            }
        }
    }
    
    private func getExposureInfo(from summary: ENExposureDetectionSummary) -> Promise<Void> {
        Promise { seal in
            let userExplanation = "Some explanation for the user, that their exposure details are being reveled to the app"
            
            exposureManager.getExposureInfo(summary: summary, userExplanation: userExplanation) { [weak self] exposureInfo, error in
                guard let info = exposureInfo, error == nil else {
                    seal.reject(error!)
                    return
                }
                
                // TODO: Map/filter info items to get appropriate information - waiting for decision
                
                // Map ENExposureInfo to some domain model - to discuss
                //seal.fulfill(())
            }
        }
    }
    
    private func makeExposureConfiguration() -> Promise<ENExposureConfiguration> {
        Promise { seal in
            configurationService.configuration()
                .done { response in
                    let configuration = ENExposureConfiguration()
                    configuration.attenuationLevelValues = response.exposure.attenuationScores.map { NSNumber(integerLiteral: $0) }
                    configuration.attenuationWeight = Double(response.exposure.attenuationWeigh)
                    configuration.daysSinceLastExposureLevelValues = response.exposure.daysSinceLastExposureScores.map { NSNumber(integerLiteral: $0) }
                    configuration.daysSinceLastExposureWeight = Double(response.exposure.daysSinceLastExposureWeight)
                    configuration.durationLevelValues = response.exposure.durationScores.map { NSNumber(integerLiteral: $0) }
                    configuration.durationWeight = Double(response.exposure.daysSinceLastExposureWeight)
                    configuration.transmissionRiskLevelValues = response.exposure.transmissionRiskScores.map { NSNumber(integerLiteral: $0) }
                    configuration.transmissionRiskWeight = Double(response.exposure.transmissionRiskWeight)
                    seal.fulfill(configuration)
                }
                .catch {
                    seal.reject($0)
                }
        }
    }
    
}
