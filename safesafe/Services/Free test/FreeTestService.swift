//
//  FreeTestService.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/10/2020.
//

import Foundation
import PromiseKit
import Moya

class FreeTestService {
    
    private let localStorage: RealmLocalStorage?
    private let deviceCheckService: DeviceCheckServiceProtocol
    private let apiProvider: MoyaProvider<FreeTestTarget>
    private let configuration: RemoteConfigProtocol
    private let renewableRequest: RenewableRequest<FreeTestTarget>
    
    private var jsOnSubscriptionInfoClosure: ((FreeTestSubscriptionInfoResponse) -> ())?
    
    init(
        with localStorage: RealmLocalStorage?,
        deviceCheckService: DeviceCheckServiceProtocol,
        apiProvider: MoyaProvider<FreeTestTarget>,
        configuration: RemoteConfigProtocol) {
        
        self.localStorage = localStorage
        self.deviceCheckService = deviceCheckService
        self.apiProvider = apiProvider
        self.renewableRequest = .init(provider: apiProvider, alertManager: NetworkingAlertManager(), notRenewableErrorCodes: [400])
        self.configuration = configuration
    }
    
    func uploadPIN(jsRequest: FreeTestUploadPinRequest) -> Promise<FreeTestPinUploadResponse> {
        deviceCheckService.generatePayload()
            .then { deviceCheckToken -> Promise<(String, DeviceGUIDModel)> in
                console("📗 Device Check Token (1/3)\n:\(deviceCheckToken)")
                return self.generateGUIDIfNeeded().map { (deviceCheckToken, $0) }
        }
        .then { deviceCheckToken, guidModel -> Promise<FreeTestCreateSubscriptionResponseModel> in
            console("📗 Generate GUID (2/3)\n:\(guidModel)")
            let headers = FreeTestRequestHeader(deviceCheckToken: deviceCheckToken)
            let request = FreeTestCreateSubscriptionRequestModel(code: jsRequest.pin, guid: guidModel.uuid)
            
            return self.createSubscription(headers: headers, request: request)
        }
        .then { apiResponse -> Promise<FreeTestPinUploadResponse> in
            console("📗 API Response (3/3)\n:\(apiResponse)")
            return .value(.init(result: .success))
        }
    }
    
    func subscriptionInfo() -> Promise<FreeTestSubscriptionInfoResponse> {
        return Promise { [weak self] seal in
            guard let guid = getGUID() else {
                seal.fulfill(.empty)
                return
            }
                    
            if guid.stateEnum == .verified {
                self?.fetchAPISubscriptionInfo(guid: guid)
            }
            
            seal.fulfill(FreeTestSubscriptionInfoResponse(with: guid))
        }
    }
    
    func jsOnSubsriptionInfo(_ closure: @escaping (FreeTestSubscriptionInfoResponse) -> ()) {
        jsOnSubscriptionInfoClosure = closure
    }
    
    func generateGUIDIfNeeded() -> Promise<DeviceGUIDModel> {
        return Promise { seal in
            if let unwrapedModel = getGUID() {
                seal.fulfill(unwrapedModel)
            } else {
                localStorage?.beginWrite()
                
                let model = DeviceGUIDModel()
                model.uuid = UUID().uuidString
                localStorage?.append(model, policy: .all)
                
                do {
                    try localStorage?.commitWrite()
                    seal.fulfill(model)
                } catch {
                    seal.reject(error)
                }
            }
        }
    }
    
    func deleteGUID() {
        guard let model = getGUID() else { return }
        
        localStorage?.beginWrite()
        
        localStorage?.remove(model)
        
        try? localStorage?.commitWrite()
    }
    
    func updateGUID(state: FreeTestSubscriptionState) {
         guard let model = getGUID() else { return }
        
        localStorage?.beginWrite()
        
        model.state = state.rawValue
        localStorage?.append(model, policy: .all)
        
        try? localStorage?.commitWrite()
    }
    
    func getPinCode() -> Promise<FreeTestPinCodeResponse> {
        Promise { seal in
            guard let model = getGUID() else { return }
            
            seal.fulfill(FreeTestPinCodeResponse(code: model.pinCode))
        }
    }
    
    func guidState() -> FreeTestSubscriptionState? {
        getGUID()?.stateEnum
    }
    
    func getGUID() -> DeviceGUIDModel? {
        localStorage?.fetch(primaryKey: DeviceGUIDModel.identifier)
    }
    
    
    private func hasUUID() -> Bool {
        getGUID() != nil
    }
    
    private func fetchAPISubscriptionInfo(guid: DeviceGUIDModel) {
        configuration.configuration()
            .then { config in
                self.deviceCheckService.generatePayload().map { (config.subscription, $0) }
        }
        .done { [weak self] config, deviceCheckToken in
            let nowTimestamp = Int(Date().timeIntervalSince1970)
            guard (nowTimestamp - guid.update) > config.interval else { return }
            
            let headers = FreeTestRequestHeader(deviceCheckToken: deviceCheckToken, accessToken: guid.token)
            let target: FreeTestTarget = .getSubscription(header: headers, request: FreeTestGetSubscriptionRequestModel(guid: guid.uuid))
            self?.apiProvider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let model = try response.map(FreeTestGetSubscriptionResponseModel.self)
                        self?.updateGUID(response: model, shouldInformJS: true)
                    } catch {
                        console(error, type: .error)
                    }
                case let .failure(error):
                    console(error, type: .error)
                }
            }
        }
        .catch {
            console($0, type: .error)
        }
    }
    
    private func updateGUID(response: FreeTestGetSubscriptionResponseModel, shouldInformJS: Bool = false) {
        guard let guid = getGUID() else { return }
        
        localStorage?.beginWrite()
        guid.state = response.status
        guid.update = Int(Date().timeIntervalSince1970)
        
        if guid.stateEnum == .signedForTest {
            guid.pinCode = nil
        }
        localStorage?.append(guid, policy: .all)
        do {
            try localStorage?.commitWrite()
        } catch {
            console(error, type: .error)
        }
        
        if shouldInformJS {
            jsOnSubscriptionInfoClosure?(FreeTestSubscriptionInfoResponse(with: guid))
        }
    }
    
    private func onSubscriptionCreateUpdate(pinCode: String, token: String) {
        guard let guid = getGUID() else { return }
        
        localStorage?.beginWrite()
        
        guid.update = Int(Date().timeIntervalSince1970)
        guid.pinCode = pinCode
        guid.token = token
        guid.state = 1
        localStorage?.append(guid, policy: .all)
        
        do {
            try localStorage?.commitWrite()
        } catch {
            console(error, type: .error)
        }
        
    }
}

// Cloud API
//
private extension FreeTestService {
    func createSubscription(headers: FreeTestRequestHeader, request: FreeTestCreateSubscriptionRequestModel) -> Promise<FreeTestCreateSubscriptionResponseModel> {
        let target: FreeTestTarget = .createSubscription(header: headers, request: request)
        return renewableRequest.make(target: target)
            .recover { error -> Promise<Response> in
                if (error as? InternalError) == nil {
                    if let moyaError = error as? MoyaError, case let .underlying(error) = moyaError {
                        console(error.0, type: .error)
                    }
                    throw InternalError.freeTestPinUploadFailed
                } else {
                    throw error
                }
        }
        .then { response -> Promise<FreeTestCreateSubscriptionResponseModel> in
            do {
                let responseModel = try response.map(FreeTestCreateSubscriptionResponseModel.self)
                self.onSubscriptionCreateUpdate(pinCode: request.code, token: responseModel.token)
                return .value(responseModel)
            } catch {
                throw error
            }
        }
        
    }
}
