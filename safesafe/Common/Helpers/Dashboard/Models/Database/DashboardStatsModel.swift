//
//  DashboardStatsModel.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 11/12/2020.
//

import Foundation
import RealmSwift

final class DashboardStatsModel: Object, LocalStorable {
    
    static let identifier = "dashboardStatsIdentifier"
    
    @objc dynamic var id: String = DashboardStatsModel.identifier
    @objc dynamic var lastFetch: Int = .zero
    @objc dynamic var updated: Int = .zero
    let currentCases = RealmOptional<Int>()
    let totalCases = RealmOptional<Int>()
    let currentDeaths = RealmOptional<Int>()
    let totalDeaths = RealmOptional<Int>()
    let currentRecovered = RealmOptional<Int>()
    let totalRecovered = RealmOptional<Int>()
    
    override class func primaryKey() -> String? { "id" }
    
    convenience init(model: DashboardStatsAPIResponse) {
        self.init()
        update(with: model)
    }
    
    convenience init(model: PushNotificationCovidStatsModel) {
        self.init()
        update(with: model)
    }
    
    func update(with model: DashboardStatsAPIResponse) {
        self.updated = model.updated
        self.currentCases.value = model.newCases
        self.totalCases.value = model.totalCases
        self.currentDeaths.value = model.newDeaths
        self.totalDeaths.value = model.totalDeaths
        self.currentRecovered.value = model.newRecovered
        self.totalDeaths.value = model.totalRecovered
    }
    
    func update(with model: PushNotificationCovidStatsModel) {
        self.updated = model.updated
        self.currentCases.value = model.newCases
        self.totalCases.value = model.totalCases
        self.currentDeaths.value = model.newDeaths
        self.totalDeaths.value = model.totalDeaths
        self.currentRecovered.value = model.newRecovered
        self.totalDeaths.value = model.totalRecovered
    }
}
