//
//  DeviceGUIDModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/10/2020.
//

import RealmSwift

class DeviceGUIDModel: Object, LocalStorable {
    
    static let identifier: Int = 22102020
    
    @objc dynamic var id: Int = DeviceGUIDModel.identifier
    @objc dynamic var uuid: String = .empty
    @objc dynamic var state: Int = .zero
    
    override class func primaryKey() -> String? { "id" }
    
    var stateEnum: FreeTestSubscriptionState {
        guard let state = FreeTestSubscriptionState(rawValue: self.state) else { return .unknown }
        
        return state
    }
}
