//
//  RenewableRequest.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 30/06/2020.
//

import Foundation
import Moya
import PromiseKit

final class RenewableRequest<Target: Moya.TargetType> {
    private var (pendingPromise, seal) = Promise<Moya.Response>.pending()
    private let provider: MoyaProvider<Target>
    private let alertManager: AlertManager
    private let notRenewableErrorCodes: [Int]
    
    init(provider: MoyaProvider<Target>, alertManager: AlertManager, notRenewableErrorCodes: [Int] = []) {
        self.provider = provider
        self.alertManager = alertManager
        self.notRenewableErrorCodes = notRenewableErrorCodes
    }
    
    func make(target: Target) -> Promise<Moya.Response> {
        defer { execute(target: target) }
        (pendingPromise, seal) = Promise<Moya.Response>.pending()
        return pendingPromise
    }
    
    private func execute(target: Target) {
        guard NetworkMonitoring.shared.isInternetAvailable else {
            alertManager.show(type: .noInternet) { [weak self] action in
                if case .cancel = action {
                    self?.seal.reject(InternalError.noInternet)
                } else if case .retry = action {
                    self?.execute(target: target)
                }
            }
            return
        }
        
        var syncResult: Swift.Result<Moya.Response, MoyaError> = .failure(.underlying(InternalError.cantMakeRequest, nil))
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global(qos: .background)
        
        provider.request(target, callbackQueue: queue) { result in
            syncResult = result
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 20)
        
        if case .failure(let error) = syncResult {
            guard let responseCode = error.response?.statusCode, (responseCode != 404 && !notRenewableErrorCodes.contains(responseCode)) else {
                seal.reject(error)
                return
            }
            
            alertManager.show(type: .uploadGeneral) { [weak self] action in
                if case .cancel = action {
                    self?.seal.reject(InternalError.cantMakeRequest)
                } else if case .retry = action {
                    self?.execute(target: target)
                }
            }
        } else if case .success(let response) = syncResult {
            seal.fulfill(response)
        }
    }
    
}

