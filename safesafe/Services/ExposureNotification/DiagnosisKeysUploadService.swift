//
//  DiagnosisKeysUploadService.swift
//  safesafe
//

import Moya
import PromiseKit

protocol DiagnosisKeysUploadServiceProtocol {
    
    func upload(usingAuthCode authCode: String) -> Promise<Void>
    
}

@available(iOS 13.5, *)
final class DiagnosisKeysUploadService: DiagnosisKeysUploadServiceProtocol {
        
    // MARK: - Properties
    
    private let exposureManager: ExposureServiceProtocol
    private let deviceCheckService: DeviceCheckServiceProtocol
    private let exposureKeysProvider: MoyaProvider<ExposureKeysTarget>
    
    // MARK: - Life Cycle
    
    init(
        with exposureManager: ExposureServiceProtocol,
        deviceCheckService: DeviceCheckServiceProtocol,
        exposureKeysProvider: MoyaProvider<ExposureKeysTarget>
    ) {
        self.exposureManager = exposureManager
        self.deviceCheckService = deviceCheckService
        self.exposureKeysProvider = exposureKeysProvider
    }
    
    // MARK: - Exposure Keys
    
    func upload(usingAuthCode authCode: String) -> Promise<Void> {
        Promise { seal in
            prepareTemporaryExposureKeys(usingAuthCode: authCode).done { keys in
                let keysData = TemporaryExposureKeysData(data: keys)
                
                self.exposureKeysProvider.request(.post(keysData)) { result in
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
    
    private func prepareTemporaryExposureKeys(usingAuthCode authCode: String) -> Promise<TemporaryExposureKeys> {
        Promise { seal in
            exposureManager
                .getDiagnosisKeys()
                .done { keys in
                    firstly { when(fulfilled:
                        self.getToken(usingAuthCode: authCode),
                        self.deviceCheckService.generatePayload(
                            bundleID: TemporaryExposureKeys.Default.appPackageName,
                            exposureKeys: keys.map({ $0.keyData }),
                            regions: TemporaryExposureKeys.Default.regions
                        )
                    )}.done { token, payload in
                        seal.fulfill(TemporaryExposureKeys(
                            temporaryExposureKeys: keys.map({ TemporaryExposureKey($0) }),
                            verificationPayload: token,
                            deviceVerificationPayload: payload
                        ))
                    }.catch {
                        seal.reject($0)
                    }
                }.catch {
                    seal.reject($0)
                }
        }
    }
    
    // MARK: - Auth
    
    private func getToken(usingAuthCode authCode: String) -> Promise<String> {
        Promise { seal in
            let data = TemporaryExposureKeysAuthData(code: authCode)
            
            exposureKeysProvider.request(.auth(data)) { result in
                switch result {
                case .success(let response):
                    do {
                        let token = try response.map(TemporaryExposureKeysAuthResponse.self).result.accessToken
                        seal.fulfill(token)
                    } catch {
                        seal.reject(error)
                    }
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
}
