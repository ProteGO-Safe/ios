//
//  DashboardStatsResponse.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 11/12/2020.
//

import Foundation

struct DashboardStatsAPIResponse: Codable {
    let updated: Int
    let newCases: Int?
    let totalCases: Int?
    let newDeaths: Int?
    let totalDeaths: Int?
    let newRecovered: Int?
    let totalRecovered: Int?
    let newVaccinations: Int
    let totalVaccinations: Int
    let newVaccinationsDose1: Int
    let totalVaccinationsDose1: Int
    let newVaccinationsDose2: Int
    let totalVaccinationsDose2: Int
}
