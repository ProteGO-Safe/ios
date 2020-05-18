//
//  TemporaryExposureKeysService.swift
//  safesafe
//

import Moya
import PromiseKit

protocol TemporaryExposureKeysServiceProtocol {
    
//    func get()
    func post() -> Promise<Void>
    
}

@available(iOS 13.5, *)
final class TemporaryExposureKeysService: TemporaryExposureKeysServiceProtocol {
        
    // MARK: - Properties
    
    private let exposureManager: ExposureManagerProtocol
    private let deviceCheckService: DeviceCheckServiceProtocol
    private let exposureKeysProvider: MoyaProvider<ExposureKeysTarget>
    
    // MARK: - Life Cycle
    
    init(
        with exposureManager: ExposureManagerProtocol,
        deviceCheckService: DeviceCheckServiceProtocol,
        exposureKeysProvider: MoyaProvider<ExposureKeysTarget>
    ) {
        self.exposureManager = exposureManager
        self.deviceCheckService = deviceCheckService
        self.exposureKeysProvider = exposureKeysProvider
    }
    
    // MARK: - Exposure Keys
    
    func post() -> Promise<Void> {
        Promise { seal in
            prepareTemporaryExposureKeys().done { keys in
                self.exposureKeysProvider.request(.post(keys)) { result in
                    switch result {
                    case .success:
                        seal.fulfill(())
                        
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
            }.catch {
                seal.reject($0)
            }
        }
    }
    
    private func prepareTemporaryExposureKeys() -> Promise<TemporaryExposureKeys> {
        Promise { seal in
            exposureManager.getDiagnosisKeys { result in
                switch result {
                case .success(let keys):
                    self.deviceCheckService.generatePayload(
                        bundleID: TemporaryExposureKeys.Default.appPackageName,
                        exposureKeys: keys.map({ $0.keyData }),
                        regions: TemporaryExposureKeys.Default.regions
                    ).done { payload in
                        seal.fulfill(TemporaryExposureKeys(
                            temporaryExposureKeys: keys.map({ TemporaryExposureKey($0) }),
                            deviceVerificationPayload: payload
                        ))
                    }.catch {
                        seal.reject($0)
                    }
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
}
