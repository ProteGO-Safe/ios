//
//  DeviceGUIDModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/10/2020.
//

import RealmSwift

class DeviceGUIDModel: Object, LocalStorable {
    
    enum State: Int {
        case unverified = 0
        case verified = 1
        case signedForTest = 2
        case utilized = 3
        case unknown = 999
    }
    
    static let identifier: Int = 22102020
    
    @objc dynamic var id: Int = DeviceGUIDModel.identifier
    @objc dynamic var uuid: String = .empty
    @objc dynamic var state: Int = .zero
    
    override class func primaryKey() -> String? { "id" }
    
    var stateEnum: State {
        guard let state = State(rawValue: self.state) else { return .unknown }
        
        return state
    }
}
