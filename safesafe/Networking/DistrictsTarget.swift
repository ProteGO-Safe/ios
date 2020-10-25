//
//  DistrictsTarget.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/10/2020.
//

import Moya

enum DistrictsTarget {
    case fetch
}

extension DistrictsTarget: TargetType {
    var baseURL: URL { URL(string: ConfigManager.default.districtsBaseURL)! }
    
    var path: String {
        switch self {
        case .fetch:
            return "/covid_info.json"
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
            return .requestParameters(parameters: ["randomSeed": "\(arc4random())"], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? { nil }
}
