//
//  ExposureService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import ExposureNotification

protocol ExposureServiceProtocol {
    
    var isExposureNotificationAuthorized: Bool { get }
    var isExposureNotificationEnabled: Bool { get }
    
    func setExposureNotificationEnabled(_ setEnabled: Bool)
    func getDiagnosisKeys(_ completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void)
    func detectExposures(_ completion: @escaping (Result<Void, Error>) -> Void)
    
}

final class ExposureService: ExposureServiceProtocol {
    
    // MARK: - Properties
    
    private let exposureManager: ENManager
    
    private var isCurrentlyDetectingExposures = false
    
    var isExposureNotificationAuthorized: Bool {
        ENManager.authorizationStatus == .authorized
    }
    
    var isExposureNotificationEnabled: Bool {
        exposureManager.exposureNotificationEnabled
    }
    
    private var nextDiagnosisKeyIndex: Int {
        get {
            StoredDefaults.standard.get(key: .nextDiagnosisKeyIndex) ?? 0
        }
        set {
            StoredDefaults.standard.set(value: newValue, key: .nextDiagnosisKeyIndex)
        }
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
        exposureManager.getDiagnosisKeys { exposureKeys, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(exposureKeys ?? []))
            }
        }
    }
    
    func detectExposures(_ completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isCurrentlyDetectingExposures else {
            return
        }
        isCurrentlyDetectingExposures = true
        
        // TODO: Should ask KeysService for configuration and keys here
        var serviceClosure: (Result<(ENExposureConfiguration, [URL]), Error>) -> Void
        
        serviceClosure = { result in
            switch result {
            case let .failure(error):
                print(error) // TODO: Error handling
                
            case let .success(configuration, urls):
                print()
            }
        }
    }
    
    // MARK: - Private methods
    
//    private func
    
}

extension StoredDefaults.Key {
    static let nextDiagnosisKeyIndex = StoredDefaults.Key("nextDiagnosisKeyIndex")
}
