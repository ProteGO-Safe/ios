//
//  CovidStatsRequest.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 13/12/2020.
//

import Foundation

struct CovidStatsRequest: Codable, JSONRepresentable {
    let isCovidStatsNotificationEnabled: Bool
}
