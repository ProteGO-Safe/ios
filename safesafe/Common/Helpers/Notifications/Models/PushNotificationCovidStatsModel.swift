//
//  PushNotificationCovidStatsModel.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 13/12/2020.
//

import Foundation

struct PushNotificationCovidStatsModel: Codable {
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

    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap {
            $0 as? [String: Any]
        }
    }
}
