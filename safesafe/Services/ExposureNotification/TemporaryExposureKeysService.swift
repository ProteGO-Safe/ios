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
    
    private let exposureService: ExposureServiceProtocol
    private let deviceCheckServiceProtocol: DCDeviceProtocol
    
    // MARK: - Life Cycle
    
    init(
        with exposureService: ExposureServiceProtocol,
        deviceCheckServiceProtocol: DCDeviceProtocol
    ) {
        self.exposureService = exposureService
        self.deviceCheckServiceProtocol = deviceCheckServiceProtocol
    }
    
}
