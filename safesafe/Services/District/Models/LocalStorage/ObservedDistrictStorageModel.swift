//
//  ObservedDistrictStorageModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/10/2020.
//

import Foundation
import RealmSwift

final class ObservedDistrictStorageModel: Object, LocalStorable {
    
    @objc dynamic var districtId: Int = -1
    @objc dynamic var name: String = .empty
    @objc dynamic var createdAt = Date()
    @objc dynamic var order: Int = .zero // for future use maybe
    
    override class func primaryKey() -> String? { "districtId" }
}
