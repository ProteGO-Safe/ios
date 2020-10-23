//
//  DeviceCheckService.swift
//  safesafe
//

import DeviceCheck
import PromiseKit

protocol DeviceCheckServiceProtocol {
    
    func generatePayload() -> Promise<String>
    
}

final class DeviceCheckService: DeviceCheckServiceProtocol {
    
    // MARK: - Properties
    
    let dcDevice: DCDeviceProtocol
    
    // MARK: - Life Cycle
    
    init(with dcDevice: DCDeviceProtocol = DCDevice.current) {
        self.dcDevice = dcDevice
    }
    
    // MARK: - ExposureNotification payload generation
    
    func generatePayload() -> Promise<String> {
        Promise { seal in
            dcDevice.generateToken { token, error in
                guard let token = token else {
                    seal.reject(InternalError.deviceCheckTokenGenerationFailed)
                    return
                }
                if let error = error {
                    seal.reject(error)
                    return
                }
                
                seal.fulfill(token.base64EncodedString())
            }
        }
    }
}
