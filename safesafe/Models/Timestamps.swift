//
//  Timestamps.swift
//  safesafe
//
//  Created by Namedix on 22/02/2021.
//

import Foundation

struct TimestampsResponse: Decodable {
    let nextUpdate: Int
    let dashboardUpdated: Int
    let detailsUpdated: Int
}
