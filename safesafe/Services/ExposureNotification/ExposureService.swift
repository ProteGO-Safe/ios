//
//  ExposureService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import ExposureNotification
import PromiseKit

@available(iOS 13.5, *)
protocol ExposureServiceProtocol: class {
    
    var isExposureNotificationAuthorized: Bool { get }
    var isExposureNotificationEnabled: Bool { get }
    
    func activateManager() -> Promise<ENStatus>
    func setExposureNotificationEnabled(_ setEnabled: Bool) -> Promise<Void>
    func getDiagnosisKeys() -> Promise<[ENTemporaryExposureKey]>
    func detectExposures() -> Promise<[Exposure]>
}

@available(iOS 13.5, *)
final class ExposureService: ExposureServiceProtocol {
    
    enum Constants {
        static let exposureInfoFullRangeRiskKey = "totalRiskScoreFullRange"
        static let attenuationDurationThresholdsKey = "attenuationDurationThresholds"
    }
    
    // MARK: - Properties
    
    private let exposureManager: ENManager
    private let diagnosisKeysService: DiagnosisKeysDownloadServiceProtocol
    private let configurationService: RemoteConfigProtocol
    private let storageService: LocalStorageProtocol?

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
        configurationService: RemoteConfigProtocol,
        storageService: LocalStorageProtocol?
    ) {
        self.exposureManager = exposureManager
        self.diagnosisKeysService = diagnosisKeysService
        self.configurationService = configurationService
        self.storageService = storageService

        if UIDevice.current.model == "iPhone"  {
            activateManager()
        }
    }
    
    deinit {
        exposureManager.invalidate()
    }
    
    // MARK: - Public methods
    
    @discardableResult
    func activateManager() -> Promise<ENStatus> {
        guard exposureManager.exposureNotificationStatus == .unknown else {
            return .value(exposureManager.exposureNotificationStatus)
        }
        
        return Promise { [weak self] seal in
            guard let self = self else {
                return seal.reject(InternalError.deinitialized)
            }
            self.exposureManager.activate { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(self.exposureManager.exposureNotificationStatus)
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
                if let error = error as? ENError {
                    switch error.code {
                    case .notAuthorized:
                        seal.reject(InternalError.shareKeysUserCanceled)
                    default:
                        seal.reject(error)
                    }
                } else {
                    seal.fulfill(exposureKeys ?? [])
                }
            }
            
            #if STAGE_DEBUG || DEV
            self?.exposureManager.getTestDiagnosisKeys(completionHandler: completion)
            #else
            self?.exposureManager.getDiagnosisKeys(completionHandler: completion)
            #endif
        }
    }
    
    func detectExposures() -> Promise<[Exposure]> {
        Promise { seal in
            firstly { when(fulfilled:
                makeExposureConfiguration(),
                diagnosisKeysService.download()
            )}
            .then { configuration, keys -> Promise<(summary: ENExposureDetectionSummary, keysCount: Int)> in
                if keys.isEmpty {
                    throw InternalError.detectExposuresNoKeys
                } else {
                    return self.detectExposures(for: configuration, keys: keys)
                }
            }
            .done { summary, numberOfKeys in
                self.getExposureInfo(from: summary, numberOfKeys: numberOfKeys)
                    .done { exposures, riskChecks, analyzeCheck in
                        ExposureHistoryRiskCheckAgregated.update(with: analyzeCheck)
                        self.storageService?.append(exposures)
                        self.storageService?.append(analyzeCheck)
                        self.storageService?.append(riskChecks)
                        seal.fulfill(exposures)
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
    
    private func countKeys(keys url: [URL]) -> Promise<(keysCount:Int, urls: [URL])> {
        Promise { seal in
            let protobufWorker = ProtobufWorker()
            seal.fulfill((keysCount: protobufWorker.countAllKeys(urls: url), urls: url))
        }
    }
    
    private func detectExposures(
        for configuration: ENExposureConfiguration,
        keys: [URL]
    ) -> Promise<(summary: ENExposureDetectionSummary, keysCount: Int)> {
        
        return countKeys(keys: keys)
            .then { keysCount, urls -> Promise<(summary: ENExposureDetectionSummary, keysCount: Int)> in
                return Promise { [weak self] seal in
                    
                    self?.exposureManager.detectExposures(
                        configuration: configuration,
                        diagnosisKeyURLs: keys
                    ) { [weak self] summary, error in
                        
                        guard let summary = summary, error == nil else {
                            console(error, type: .error)
                            seal.reject(error!)
                            return
                        }
                        console("📈 \(summary)", type: .regular)
                        seal.fulfill((summary: summary, keysCount: keysCount))
                        self?.diagnosisKeysService.deleteFiles()
                    }
                    
                }
            }
    }
    
    
    private func getExposureInfo(
        from summary: ENExposureDetectionSummary,
        numberOfKeys: Int
    ) -> Promise<(exposures: [Exposure], riskChecks: [ExposureHistoryRiskCheck], analyzeCheck: ExposureHistoryAnalyzeCheck)> {
        
        Promise { seal in
            
            let userExplanation = "EXPOSURE_INFO_EXPLANATION".localized()
            let esposureRisk = ExposureHistoryAnalyzeCheck(matchedKeyCount: Int(summary.matchedKeyCount), keysCount: numberOfKeys)
            
            exposureManager.getExposureInfo(summary: summary, userExplanation: userExplanation) { exposureInfo, error in
                guard let info = exposureInfo, error == nil else {
                    seal.reject(error!)
                    return
                }
                
                var exposures: [Exposure] = []
                let riskChecks: [ExposureHistoryRiskCheck]
                if info.isEmpty {
                    riskChecks = [.init(matchedKeyCount: Int(summary.matchedKeyCount), riskLevelFull: .zero)]
                } else {
                    riskChecks = info.compactMap { info -> ExposureHistoryRiskCheck? in
                        guard let risk = info.metadata?[Constants.exposureInfoFullRangeRiskKey] as? Int else {
                            return nil
                        }
                        
                        return .init(matchedKeyCount: Int(summary.matchedKeyCount), riskLevelFull: risk)
                    }
                    
                    exposures = info.compactMap { info -> Exposure? in
                        guard let risk = info.metadata?[Constants.exposureInfoFullRangeRiskKey] as? Int else {
                            return nil
                        }
                        
                        return .init(risk: risk, duration: info.duration * 60, date: info.date)
                    }
                }
                
                seal.fulfill((exposures: exposures, riskChecks: riskChecks, analyzeCheck: esposureRisk))
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
                    configuration.metadata = [Constants.attenuationDurationThresholdsKey: response.exposure.durationAtAttenuationThresholds]
                    seal.fulfill(configuration)
                }
                .recover { _ in
                    // Default configuration - in case something goes wrong on Firebase side
                    let configuration = ENExposureConfiguration()
                    configuration.attenuationLevelValues = [2,5,6,7,8,8,8,8]
                    configuration.attenuationWeight = 50
                    configuration.daysSinceLastExposureLevelValues = [7,8,8,8,8,8,8,8]
                    configuration.daysSinceLastExposureWeight = 50
                    configuration.durationLevelValues = [0,5,6,7,8,8,8,8]
                    configuration.durationWeight = 50
                    configuration.transmissionRiskLevelValues = [8,8,8,8,8,8,8,8]
                    configuration.transmissionRiskWeight = 50
                    configuration.metadata = [Constants.attenuationDurationThresholdsKey: [48, 58]]
                    seal.fulfill(configuration)
                }
        }
    }
}

@available(iOS 13.5, *)
extension ExposureService: ExposureNotificationStatusProtocol {
    var status: Promise<ServicesResponse.Status.ExposureNotificationStatus> {
        guard UIDevice.current.model == "iPhone" else { return .value(.restricted) }
        
        return activateManager().map {
            if ENManager.authorizationStatus != .authorized {
                return .off
            } else {
                switch $0 {
                case .active: return .on
                case .bluetoothOff, .disabled: return .off
                default: return .restricted
                }
            }
        }
    }
    
    func isBluetoothOn(delay: TimeInterval) -> Promise<Bool> {
        guard UIDevice.current.model == "iPhone" else { return .value(false) }
        
        if delay == .zero {
            return activateManager().map { $0 != .bluetoothOff }
        }
        
        // Discussion: this is a workaround, because `exposureManager.exposureNotificationStatus` returns `.disabled` on first check
        // and a moment later status is updated to `.bluetoothOff` (if BT is off in system settings). So we use short delay to manage this issue.
        return after(seconds: delay)
            .then { _ -> Promise<ENStatus> in
                self.activateManager()
        }.map { $0 != .bluetoothOff }
    }
}
