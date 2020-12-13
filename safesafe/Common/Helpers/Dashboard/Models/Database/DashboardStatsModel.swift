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
    @objc dynamic var currentCases: Int = .zero
    @objc dynamic var totalCases: Int = .zero
    @objc dynamic var currentDeaths: Int = .zero
    @objc dynamic var totalDeaths: Int = .zero
    @objc dynamic var currentRecovered: Int = .zero
    @objc dynamic var totalRecovered: Int = .zero
    
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
        self.currentCases = model.newCases
        self.totalCases = model.totalCases
        self.currentDeaths = model.newDeaths
        self.totalDeaths = model.totalDeaths
        self.currentRecovered = model.newRecovered
        self.totalDeaths = model.totalRecovered
    }
    
    func update(with model: PushNotificationCovidStatsModel) {
        self.updated = model.updated
        self.currentCases = model.newCases
        self.totalCases = model.totalCases
        self.currentDeaths = model.newDeaths
        self.totalDeaths = model.totalDeaths
        self.currentRecovered = model.newRecovered
        self.totalDeaths = model.totalRecovered
    }
}
