//
//  DashboardStatsResponse.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 11/12/2020.
//

import Foundation

struct DashboardStatsResponse: Codable, JSONRepresentable {
    let covidStats: CovidStats?
    
    struct CovidStats: Codable {
        let newCases: Int?
        let totalCases: Int?
        let newDeaths: Int?
        let totalDeaths: Int?
        let newRecovered: Int?
        let totalRecovered: Int?
        // Vaccination
        let newVaccinations: Int?
        let totalVaccinations: Int?
        let newVaccinationsDose1: Int?
        let totalVaccinationsDose1: Int?
        let newVaccinationsDose2: Int?
        let totalVaccinationsDose2: Int?
        
        init(with model: DashboardStatsModel) {
            self.newCases = model.currentCases.value
            self.totalCases = model.totalCases.value
            self.newDeaths = model.currentDeaths.value
            self.totalDeaths = model.totalDeaths.value
            self.newRecovered = model.currentRecovered.value
            self.totalRecovered = model.totalRecovered.value
            self.newVaccinations = model.currentVaccinations.value
            self.totalVaccinations = model.totalVaccinations.value
            self.newVaccinationsDose1 = model.currentVaccinationsDose1.value
            self.totalVaccinationsDose1 = model.totalVaccinationsDose1.value
            self.newVaccinationsDose2 = model.currentVaccinationsDose2.value
            self.totalVaccinationsDose2 = model.totalVaccinationsDose2.value
        }
    }
}
