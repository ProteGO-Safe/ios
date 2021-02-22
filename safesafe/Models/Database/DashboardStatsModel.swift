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
    let currentCases = RealmOptional<Int>()
    let totalCases = RealmOptional<Int>()
    let currentDeaths = RealmOptional<Int>()
    let totalDeaths = RealmOptional<Int>()
    let currentRecovered = RealmOptional<Int>()
    let totalRecovered = RealmOptional<Int>()
    let currentVaccinations = RealmOptional<Int>()
    let totalVaccinations = RealmOptional<Int>()
    let currentVaccinationsDose1 = RealmOptional<Int>()
    let totalVaccinationsDose1 = RealmOptional<Int>()
    let currentVaccinationsDose2 = RealmOptional<Int>()
    let totalVaccinationsDose2 = RealmOptional<Int>()
    
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
        self.currentCases.value = model.newCases
        self.totalCases.value = model.totalCases
        self.currentDeaths.value = model.newDeaths
        self.totalDeaths.value = model.totalDeaths
        self.currentRecovered.value = model.newRecovered
        self.totalRecovered.value = model.totalRecovered
        self.currentVaccinations.value = model.newVaccinations
        self.totalVaccinations.value = model.totalVaccinations
        self.currentVaccinationsDose1.value = model.newVaccinationsDose1
        self.totalVaccinationsDose1.value = model.totalVaccinationsDose1
        self.currentVaccinationsDose2.value = model.newVaccinationsDose2
        self.totalVaccinationsDose2.value = model.totalVaccinationsDose2
    }
    
    func update(with model: PushNotificationCovidStatsModel) {
        self.currentCases.value = model.newCases
        self.totalCases.value = model.totalCases
        self.currentDeaths.value = model.newDeaths
        self.totalDeaths.value = model.totalDeaths
        self.currentRecovered.value = model.newRecovered
        self.totalRecovered.value = model.totalRecovered
        self.currentVaccinations.value = model.newVaccinations
        self.totalVaccinations.value = model.totalVaccinations
        self.currentVaccinationsDose1.value = model.newVaccinationsDose1
        self.totalVaccinationsDose1.value = model.totalVaccinationsDose1
        self.currentVaccinationsDose2.value = model.newVaccinationsDose2
        self.totalVaccinationsDose2.value = model.totalVaccinationsDose2
    }
}
