//
//  ExposureManager.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import ExposureNotification

protocol ExposureManagerProtocol {
    
    var isExposureNotificationAuthorized: Bool { get }
    var isExposureNotificationEnabled: Bool { get }
    
    func setExposureNotificationEnabled(_ setEnabled: Bool)
    func getDiagnosisKeys(_ completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void)
    func detectExposures(_ completion: @escaping (Result<Void, Error>) -> Void)
    
}

final class ExposureManager: ExposureManagerProtocol {
    
    // MARK: - Properties
    
    private let exposureManager: ENManager
    
    private var isCurrentlyDetectingExposures = false
    
    var isExposureNotificationAuthorized: Bool {
        ENManager.authorizationStatus == .authorized
    }
    
    var isExposureNotificationEnabled: Bool {
        exposureManager.exposureNotificationEnabled
    }
    
    // MARK: - Life Cycle
    
    init(exposureManager: ENManager) {
        self.exposureManager = exposureManager
        
        self.exposureManager.activate { error in
            // TODO: Error handling
        }
    }
    
    deinit {
        exposureManager.invalidate()
    }
    
    // MARK: - Public methods
    
    func setExposureNotificationEnabled(_ setEnabled: Bool) {
        exposureManager.setExposureNotificationEnabled(setEnabled) { error in
            // TODO: Error handling
        }
    }
    
    func getDiagnosisKeys(_ completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void) {
        let key = ENTemporaryExposureKey()
        completion(.success([key]))
        
//        exposureManager.getDiagnosisKeys { exposureKeys, error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(exposureKeys ?? []))
//            }
//        }
    }
    
    func detectExposures(_ completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
}
