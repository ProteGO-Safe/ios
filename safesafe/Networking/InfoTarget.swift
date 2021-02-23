//
//  InfoTarget.swift
//  safesafe
//
//  Created by Namedix on 23/02/2021.
//

import Moya

enum InfoTarget {
    case fetchTimestamps
    case fetchDashboard
    case fetchDetails
    case fetchDistricts
}

extension InfoTarget: TargetType {
    var baseURL: URL { URL(string: ConfigManager.default.baseURL)! }

    var path: String {
        switch self {
        case .fetchTimestamps:
            return "/timestamps.json"
        case .fetchDashboard:
            return "/dashboard.json"
        case .fetchDetails:
            return "/details.json"
        case .fetchDistricts:
            return "/districts.json"
        }
    }

    var method: Method {
        return .get
    }

    var sampleData: Data { .init() }

    var task: Task {
        return .requestParameters(
            parameters: ["randomSeed": "\(arc4random())"],
            encoding: URLEncoding.default
        )
    }

    var headers: [String : String]? { nil }
}
