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
        let newCases: Int
        let totalCases: Int
        let newDeaths: Int
        let totalDeaths: Int
        let newRecovered: Int
        let totalRecovered: Int
        
        init(with model: DashboardStatsModel) {
            self.updated = model.updated
            self.newCases = model.currentCases
            self.totalCases = model.totalCases
            self.newDeaths = model.currentDeaths
            self.totalDeaths = model.totalDeaths
            self.newRecovered = model.currentRecovered
            self.totalRecovered = model.totalRecovered
        }
    }
}
