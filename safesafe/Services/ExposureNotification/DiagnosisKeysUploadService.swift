//
//  DiagnosisKeysUploadService.swift
//  safesafe
//

import Moya
import PromiseKit
import ExposureNotification

protocol DiagnosisKeysUploadServiceProtocol {
    
    func upload(usingAuthCode authCode: String) -> Promise<Void>
    
}

enum UploadError: Error {
    case noInternet(shouldRetry: Bool)
    case general(shouldRetry: Bool, code: Int)
    case unknown(Error)
}

@available(iOS 13.5, *)
final class DiagnosisKeysUploadService: DiagnosisKeysUploadServiceProtocol {
        
    private enum Constants {
        static let dayIntervalSeconds: UInt32 = 86400
        static let keyExpirationDays: UInt32 = 14
        static let rollingIterationSeconds: UInt32 = 600
    }
    
    private enum Validation {
        static let keysAtLeast = 1
        static let keysMax = 30
        static let keysPerDayMax = 3
    }
    
    // MARK: - Properties
    
    private let exposureManager: ExposureServiceProtocol
    private let deviceCheckService: DeviceCheckServiceProtocol
    private let renewableRequest: RenewableRequest<ExposureKeysTarget>
    
    // MARK: - Life Cycle
    
    init(
        with exposureManager: ExposureServiceProtocol,
        deviceCheckService: DeviceCheckServiceProtocol,
        exposureKeysProvider: MoyaProvider<ExposureKeysTarget>
    ) {
        self.exposureManager = exposureManager
        self.deviceCheckService = deviceCheckService
        self.renewableRequest = .init(provider: exposureKeysProvider, alertManager: NetworkingAlertManager())
    }
    
    // MARK: - Exposure Keys
    
    func upload(usingAuthCode authCode: String) -> Promise<Void> {
        var diagnosisKeys: [ENTemporaryExposureKey] = []
        return getDiagnosisKeys()
            .then (validateKeysAtLeast)
            .then (validateKeysMax)
            .then(validateKeysPerDayMax)
            .then { keys -> Promise<String> in
                diagnosisKeys = keys
                return self.getToken(usingAuthCode: authCode)
        }
        .then { token -> Promise<Moya.Response> in
            let data = TemporaryExposureKeys(
                temporaryExposureKeys: diagnosisKeys.map({ TemporaryExposureKey($0) }),
                verificationPayload: token            )
            let keysData = TemporaryExposureKeysData(data: data)
            
            #if !LIVE
            File.saveUploadedPayload(keysData)
            #endif
            
            return self.renewableRequest.make(target: .post(keysData))
        }
        .asVoid()
    }
    
    private func getDiagnosisKeys(filtered: Bool = true) -> Promise<[ENTemporaryExposureKey]> {
        if filtered {
            return exposureManager
                .getDiagnosisKeys()
                .filterValues(discardOldKeys)
        } else {
            return exposureManager
                .getDiagnosisKeys()
        }
    }
    
    // MARK: - Auth
    
    private func getToken(usingAuthCode authCode: String) -> Promise<String> {
        let data = TemporaryExposureKeysAuthData(code: authCode)
        return renewableRequest.make(target: .auth(data))
            .then { response -> Promise<String> in
                do {
                    let token = try response.map(TemporaryExposureKeysAuthResponse.self).result.accessToken
                    return .value(token)
                } catch {
                    throw error
                }
        }
    }
    
    private func discardOldKeys(key: ENTemporaryExposureKey) -> Bool {
        let startOfDay = UInt32(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970)
        let valid = (key.rollingStartNumber * Constants.rollingIterationSeconds) > (startOfDay - Constants.keyExpirationDays * Constants.dayIntervalSeconds)
        if !valid { console(">>> Discarded Key> Rolling Start Number: \(key.rollingStartNumber), Rolling Period: \(key.rollingPeriod)", type: .warning) }
        return valid
    }
    
    private func validateKeysAtLeast(_ keys: [ENTemporaryExposureKey]) -> Promise<[ENTemporaryExposureKey]> {
        console("keys count: \(keys.count)")
        if keys.count < Validation.keysAtLeast {
            UploadValidationAlertManager().show(type: .keysAtLeast) { _ in }
            return .init(error: InternalError.uploadValidation)
        }
        return .value(keys)
    }
    
    private func validateKeysMax(_ keys: [ENTemporaryExposureKey]) -> Promise<[ENTemporaryExposureKey]> {
        console("keys count: \(keys.count)")
        if keys.count > Validation.keysMax {
            UploadValidationAlertManager().show(type: .keysMax) { _ in }
            return .init(error: InternalError.uploadValidation)
        }
        return .value(keys)
    }
    
    private func validateKeysPerDayMax(_ keys: [ENTemporaryExposureKey]) -> Promise<[ENTemporaryExposureKey]> {
        let rollingPeriods = keys.map { ($0.rollingStartNumber, 1) }
        let rollingPeriodsCount = Dictionary(rollingPeriods, uniquingKeysWith: +)
  
        if rollingPeriodsCount.filter ({ $1 > Validation.keysPerDayMax }).count > .zero {
            UploadValidationAlertManager().show(type: .keysPerDayMax) { _ in }
            return .init(error: InternalError.uploadValidation)
        }
        
        return .value(keys)
    }
}
