//
//  DetailsTarget.swift
//  safesafe
//
//  Created by Namedix on 19/02/2021.
//

import Moya

enum DetailsTarget {
    case fetch
}

extension DetailsTarget: TargetType {
    var baseURL: URL { URL(string: ConfigManager.default.baseURL)! }

    var path: String {
        switch self {
        case .fetch:
            return "/details.json"
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

    /*
     var task: Task {
     switch self {
     case .fetch:
     return .requestParameters(parameters: ["randomSeed": "\(arc4random())"], encoding: URLEncoding.default)
     }
     }
     */

    var headers: [String : String]? { nil }
}
