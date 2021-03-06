//
//  DeviceGUIDModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/10/2020.
//

import RealmSwift
import Foundation

class DeviceGUIDModel: Object, LocalStorable {
    
    static let identifier: Int = 22102020
    
    @objc dynamic var id: Int = DeviceGUIDModel.identifier
    @objc dynamic var uuid: String = .empty
    @objc dynamic var state: Int = .zero
    @objc dynamic var update: Int = .zero
    @objc dynamic var token: String?
    @objc dynamic var pinCode: String?
    
    override class func primaryKey() -> String? { "id" }
    
    var stateEnum: FreeTestSubscriptionState {
        guard let state = FreeTestSubscriptionState(rawValue: self.state) else { return .unknown }
        
        return state
    }
}
