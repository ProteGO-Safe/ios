//
//  VoivodeshipStorageModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/10/2020.
//

import Foundation
import RealmSwift

final class VoivodeshipStorageModel: Object, LocalStorable {
    
    @objc dynamic var id: Int = .zero
    @objc dynamic var name: String = .empty
    @objc dynamic var updatedAt: Int = .zero
    @objc dynamic var order: Int = .zero
    let districts = LinkingObjects(fromType: DistrictStorageModel.self, property: "voivodeship")
    
    override class func primaryKey() -> String? { "id" }
    
    convenience init(with voivodeshipAPIModel: DistrictResponseModel.Voivodeship, index: Int, updatedAt: Int) {
        self.init()
        
        self.id = voivodeshipAPIModel.id
        self.name = voivodeshipAPIModel.name
        self.updatedAt = updatedAt
        self.order = index
    }
}
