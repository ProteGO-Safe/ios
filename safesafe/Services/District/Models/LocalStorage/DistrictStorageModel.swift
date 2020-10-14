//
//  DistrictStorageModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/10/2020.
//

import Foundation
import RealmSwift

final class DistrictStorageModel: Object, LocalStorable {
    
    private static let initState: Int = -1
    
    @objc dynamic var id: Int = .zero
    @objc dynamic var name: String = .empty
    @objc dynamic var state: Int = DistrictStorageModel.initState
    @objc dynamic var lastState: Int = DistrictStorageModel.initState
    @objc dynamic var updatedAt: Int = .zero
    @objc dynamic var order: Int = .zero
    @objc dynamic var voivodeship: VoivodeshipStorageModel?
    
    var stateChanged: Bool {  lastState != state }
    var localizedZoneName: String {
        switch state {
        case 0:
            return "DISTRICT_ZONE_NEUTRAL".localized()
        case 1:
            return "DISTRICT_ZONE_YELLOW".localized()
        case 2:
            return "DISTRICT_ZONE_RED".localized()
        default:
            return .empty
        }
    }
    
    override class func primaryKey() -> String? { "id" }
    
    convenience init(
        with districtAPIModel: DistrictResponseModel.Voivodeship.District,
        currentModel: DistrictStorageModel?,
        voivodeship: VoivodeshipStorageModel?,
        index: Int,
        updatedAt: Int
    ) {
    
        self.init()
        
        self.id = districtAPIModel.id
        self.name = districtAPIModel.name
        self.updatedAt = updatedAt
        self.state = districtAPIModel.state
        self.order = index
        
        if let currentModel = currentModel {
            self.lastState = currentModel.state
        } else {
            self.lastState = districtAPIModel.state
        }
        
        self.voivodeship = voivodeship
    }
}
