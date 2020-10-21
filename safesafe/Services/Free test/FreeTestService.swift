//
//  FreeTestService.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/10/2020.
//

import Foundation

class FreeTestService {
    
    private let localStorage: RealmLocalStorage?
    private let deviceCheckService: DeviceCheckServiceProtocol
    
    init(
        with localStorage: RealmLocalStorage?,
        deviceCheckService: DeviceCheckServiceProtocol) {
        
        self.localStorage = localStorage
        self.deviceCheckService = deviceCheckService
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
    
    func updateGUID(state: DeviceGUIDModel.State) {
         guard let model = getGUID() else { return }
        
        localStorage?.beginWrite()
        
        model.state = state.rawValue
        
        try? localStorage?.commitWrite()
    }
    
    func guidState() -> DeviceGUIDModel.State? {
        getGUID()?.stateEnum
    }
    
    private func getGUID() -> DeviceGUIDModel? {
        localStorage?.fetch(primaryKey: DeviceGUIDModel.identifier)
    }
    
    private func hasUUID() -> Bool {
        getGUID() != nil
    }
}
