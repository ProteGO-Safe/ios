//
//  RemoteConfig.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/05/2020.
//

import Foundation
import PromiseKit
import FirebaseRemoteConfig

protocol RemoteConfigProtocol {
    func configuration() -> Promise<RemoteConfigurationResponse>
}

final class RemoteConfiguration: RemoteConfigProtocol {
    
    private enum Key: String {
        case diagnosisKeyConfig = "diagnosisKeyDownloadConfiguration"
        case exposureConfiguration = "exposureConfiguration"
    }
        
    private let decoder = JSONDecoder()
    private let remoteConfig: RemoteConfig
    
    init(settings: RemoteConfigSettings? = nil) {
        self.remoteConfig = RemoteConfig.remoteConfig()
        if let settings = settings {
            self.remoteConfig.configSettings = settings
        }
    }
    
    func configuration() -> Promise<RemoteConfigurationResponse> {
        let timeout = after(seconds: 5)
        let config = fetchConfiguration()
        return race(config.asVoid(), timeout.asVoid())
            .then { _ -> Promise<RemoteConfigurationResponse> in
                if timeout.isResolved {
                    return .init(error: InternalError.timeout)
                } else if let value = config.value {
                    return .value(value)
                } else {
                    return .init(error: InternalError.nilValue)
                }
        }
    }
    
    private func fetchConfiguration() -> Promise<RemoteConfigurationResponse> {
        return Promise { seal in
                   remoteConfig.fetchAndActivate { [weak self] status, error in
                       guard let self = self else {
                           seal.reject(InternalError.deinitialized)
                           return
                       }
                       
                       if let error = error {
                           seal.reject(error)
                       } else {
                           switch status {
                           case .successFetchedFromRemote, .successUsingPreFetchedData:
                               do {
                                   let diagnosis: DiagnosisKeyDownloadConfiguration = try self.decodeConfiguartion(key: .diagnosisKeyConfig)
                                   let exposure: ExposureConfiguration = try self.decodeConfiguartion(key: .exposureConfiguration)
                                   seal.fulfill(RemoteConfigurationResponse(diagnosis: diagnosis, exposure: exposure))
                               } catch {
                                   seal.reject(error)
                               }
                           case .error:
                               seal.reject(InternalError.remoteActivate)
                           @unknown default:
                               seal.reject(InternalError.remoteUnknownStatus)
                           }
                       }
                   }
               }
    }
    
  private func decodeConfiguartion<T: Decodable>(key: Key) throws -> T {
        guard let jsonValue = remoteConfig[key.rawValue].jsonValue else {
            throw InternalError.remoteConfigNotExistingKey
        }
        let data = try JSONSerialization.data(withJSONObject: jsonValue, options: [])
        return try decoder.decode(T.self, from: data)
    }
}
