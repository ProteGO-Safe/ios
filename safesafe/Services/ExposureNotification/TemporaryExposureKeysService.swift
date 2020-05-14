//
//  TemporaryExposureKeysService.swift
//  safesafe
//

import Foundation

protocol TemporaryExposureKeysServiceProtocol {
    
//    func get()
//    func post()
    
}

final class TemporaryExposureKeysService: TemporaryExposureKeysServiceProtocol {
    
    // MARK: - Properties
    
    private let exposureManager: ExposureManagerProtocol
    private let deviceCheckServiceProtocol: DeviceCheckServiceProtocol
    
    // MARK: - Life Cycle
    
    init(
        with exposureManager: ExposureManagerProtocol,
        deviceCheckServiceProtocol: DeviceCheckServiceProtocol
    ) {
        self.exposureManager = exposureManager
        self.deviceCheckServiceProtocol = deviceCheckServiceProtocol
    }
    
}
