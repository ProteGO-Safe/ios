//
//  FreeTestService.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/10/2020.
//

import Foundation
import PromiseKit

class FreeTestService {
    
    private let localStorage: RealmLocalStorage?
    private let deviceCheckService: DeviceCheckServiceProtocol
    
    private var jsOnSubscriptionInfoClosure: ((FreeTestSubscriptionInfoResponse) -> ())?
    
    init(
        with localStorage: RealmLocalStorage?,
        deviceCheckService: DeviceCheckServiceProtocol) {
        
        self.localStorage = localStorage
        self.deviceCheckService = deviceCheckService
    }
    
    func uploadPIN(pin: FreeTestUploadPinRequest) -> Promise<FreeTestPinUploadResponse> {
        return Promise { seal in
            fatalError("Not implemented yet")
        }
    }
    
    func subscriptionInfo() -> Promise<FreeTestSubscriptionInfoResponse> {
        return Promise { seal in
            fatalError("Not implemented yet")
        }
    }
    
    func jsOnSubsriptionInfo(_ closure: @escaping (FreeTestSubscriptionInfoResponse) -> ()) {
        jsOnSubscriptionInfoClosure = closure
    }
    
    func generateGUID() {
        guard !hasUUID() else { return }
        
        localStorage?.beginWrite()
        
        let model = DeviceGUIDModel()
        model.uuid = UUID().uuidString
        
        try? localStorage?.commitWrite()
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
        
        try? localStorage?.commitWrite()
    }
    
    func guidState() -> FreeTestSubscriptionState? {
        getGUID()?.stateEnum
    }
    
    private func getGUID() -> DeviceGUIDModel? {
        localStorage?.fetch(primaryKey: DeviceGUIDModel.identifier)
    }
    
    private func hasUUID() -> Bool {
        getGUID() != nil
    }
}
