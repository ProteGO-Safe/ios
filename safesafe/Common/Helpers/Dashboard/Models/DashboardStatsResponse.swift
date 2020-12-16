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
        let updated: Int
        let newCases: Int?
        let totalCases: Int?
        let newDeaths: Int?
        let totalDeaths: Int?
        let newRecovered: Int?
        let totalRecovered: Int?
        
        init(with model: DashboardStatsModel) {
            self.updated = model.updated
            self.newCases = model.currentCases.value
            self.totalCases = model.totalCases.value
            self.newDeaths = model.currentDeaths.value
            self.totalDeaths = model.totalDeaths.value
            self.newRecovered = model.currentRecovered.value
            self.totalRecovered = model.totalRecovered.value
        }
    }
}
