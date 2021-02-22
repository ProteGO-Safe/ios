//
//  DashboardTarget.swift
//  safesafe
//
//  Created by Namedix on 19/02/2021.
//

import Moya

enum DashboardTarget {
    case fetch
}

extension DashboardTarget: TargetType {
    var baseURL: URL { URL(string: ConfigManager.default.baseURL)! }

    var path: String {
        switch self {
        case .fetch:
            return "/dashboard.json"
        }
    }

    var method: Method {
        switch self {
        case .fetch:
            return .get
        }
    }

    var sampleData: Data { .init() }

    var task: Task {
        switch self {
        case .fetch:
            return .requestPlain
        }
    }

    var headers: [String : String]? { nil }
}
