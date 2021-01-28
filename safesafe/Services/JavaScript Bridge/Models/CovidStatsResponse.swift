//
//  CovidStatsResponse.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 13/12/2020.
//

import Foundation

struct CovidStatsResponse: Codable, JSONRepresentable {
    let isCovidStatsNotificationEnabled: Bool
}
