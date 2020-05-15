//
//  DeviceCheckService.swift
//  safesafe
//

import DeviceCheck

protocol DeviceCheckServiceProtocol {
    
    func generatePayload(
        using bundleID: String,
        exposureKeys: [Data],
        regions: [String],
        completion: @escaping (Result<String, Error>) -> Void
    )
    
}

final class DeviceCheckService: DeviceCheckServiceProtocol {
    
    // MARK: - Properties
    
    let dcDevice: DCDeviceProtocol
    
    // MARK: - Life Cycle
    
    init(with dcDevice: DCDeviceProtocol = DCDevice.current) {
        self.dcDevice = dcDevice
    }
    
    // MARK: - ExposureNotification payload generation
    
    func generatePayload(
        using bundleID: String,
        exposureKeys: [Data],
        regions: [String],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let transactionID = (bundleID + concatenate(exposureKeys) + concatenate(regions)).sha256() else {
            completion(.failure(InternalError.deviceCheckTokenGenerationFailed))
            return
        }
        
        dcDevice.generateToken { token, error in
            guard let token = token, error == nil else {
                completion(.failure(error ?? InternalError.deviceCheckTokenGenerationFailed))
                return
            }
            
            let deviceVerification = DeviceVerification(
                deviceToken: token.base64EncodedString(),
                transactionId: transactionID,
                timestamp: Int(Date().timeIntervalSince1970) * 1000
            )
            
            guard let jsonData = try? JSONEncoder().encode(deviceVerification) else {
                completion(.failure(InternalError.jsonSerializingData))
                return
            }
            
            completion(.success(jsonData.base64EncodedString()))
        }
    }
    
    private func concatenate(_ exposureKeys: [Data]) -> String {
        return exposureKeys
            .map({ $0.base64EncodedString() })
            .sorted(by: <)
            .reduce("", +)
    }
    
    private func concatenate(_ regions: [String]) -> String {
        return regions
            .map({ $0.uppercased() })
            .sorted(by: <)
            .reduce("", +)
    }
    
}
