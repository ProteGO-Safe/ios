//
//  ExposureManager.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import ExposureNotification

protocol ExposureManagerProtocol {
    
    var isExposureNotificationAuthorized: Bool { get }
    
    func detectExposures(_ completion: (Result<Void, Error>) -> Void)
    
}

final class ExposureManager: ExposureManagerProtocol {
    
    // MARK: - Properties
    
    var isExposureNotificationAuthorized: Bool {
        ENManager.authorizationStatus == .authorized
    }
    
    // MARK: - Public methods
    
    func detectExposures(_ completion: (Result<Void, Error>) -> Void) {
        
    }
    
}
