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
    
    func setExposureNotificationEnabled(_ setEnabled: Bool, completion: @escaping (Error?) -> ())
    func getDiagnosisKeys(_ completion: @escaping (Swift.Result<[ENTemporaryExposureKey], Error>) -> Void)
    func detectExposures(_ completion: @escaping (Swift.Result<Void, Error>) -> Void)
    
}

@available(iOS 13.5, *)
protocol ExposureNotificationManagable: class {
    func activateManager() -> Promise<Void>
    func serviceTurnOn() -> Promise<Void>
    func serviceTurnOff() -> Promise<Void>
    func authorizationStatus() -> Promise<ENAuthorizationStatus>
    func status() -> Promise<ENStatus>
}

@available(iOS 13.5, *)
final class ExposureService: ExposureServiceProtocol {
    // MARK: - Properties
    
    private let exposureManager: ENManager
    private let keysService: TemporaryExposureKeysServiceProtocol
    
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
        keysService: TemporaryExposureKeysServiceProtocol
    ) {
        self.exposureManager = exposureManager
        self.keysService = keysService
    }
    
    deinit {
        exposureManager.invalidate()
    }
    
    // MARK: - Public methods
    func setExposureNotificationEnabled(_ setEnabled: Bool, completion: @escaping (Error?) -> ()) {
        exposureManager.setExposureNotificationEnabled(setEnabled) { error in
            completion(error)
            // TODO: Error handling
        }
    }
    
    func getDiagnosisKeys(_ completion: @escaping (Swift.Result<[ENTemporaryExposureKey], Error>) -> Void) {
        exposureManager.getDiagnosisKeys { exposureKeys, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(exposureKeys ?? []))
            }
        }
    }
    
    func detectExposures(_ completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        guard !isCurrentlyDetectingExposures else {
            return
        }
        isCurrentlyDetectingExposures = true
        
        // TODO: Should ask KeysService for configuration and key urls here
        var serviceClosure: (Swift.Result<(ENExposureConfiguration, [URL]), Error>) -> Void
        
        serviceClosure = { [weak self] result in
            switch result {
            case let .failure(error):
                self?.endExposureSession(with: .failure(error))
                completion(.failure(error))
                
            case let .success((configuration, urls)):
                self?.exposureManager.detectExposures(configuration: configuration, diagnosisKeyURLs: urls) { summary, error in
                    guard let summary = summary, error == nil else {
                        self?.endExposureSession(with: .failure(error!))
                        completion(.failure(error!))
                        return
                    }
                    
                    self?.getExposureInfo(from: summary, completion)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func getExposureInfo(
        from summary: ENExposureDetectionSummary,
        _ completion: @escaping (Swift.Result<Void, Error>) -> Void
    ) {
        let userExplanation = "Some explanation for the user, that their exposure details are being reveled to the app"
        
        exposureManager.getExposureInfo(summary: summary, userExplanation: userExplanation) { [weak self] exposureInfo, error in
            guard let info = exposureInfo, error == nil else {
                self?.endExposureSession(with: .failure(error!))
                completion(.failure(error!))
                return
            }
            
            // Map ENExposureInfo to some domain model - to discuss
            self?.endExposureSession(with: .success)
            completion(.success)
        }
    }
    
    // TODO: Some other successful result should be here - to discuss (probably `[Exposure]` like in Apple's sample)
    private func endExposureSession(with result: Swift.Result<Void, Error>) {
        
    }
    
}

@available(iOS 13.5, *)
extension ExposureService: ExposureNotificationManagable {
    func activateManager() -> Promise<Void> {
        guard exposureManager.exposureNotificationStatus == .unknown else {
            return .value
        }
        return Promise { seal in
            self.exposureManager.activate { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
        }
    }
    
    func serviceTurnOn() -> Promise<Void> {
        return Promise { seal in
            setExposureNotificationEnabled(true) { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
        }
    }
    
    func serviceTurnOff() -> Promise<Void> {
        return Promise { seal in
            setExposureNotificationEnabled(false) { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
        }
    }
    
    func authorizationStatus() -> Promise<ENAuthorizationStatus> {
        return .value(ENManager.authorizationStatus)
    }
    
    func status() -> Promise<ENStatus> {
        return .value(exposureManager.exposureNotificationStatus)
    }
}
