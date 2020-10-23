//
//  FreeTestTarget.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 22/10/2020.
//

import Moya

enum FreeTestTarget {
    case createSubscription(header: FreeTestRequestHeader, request: FreeTestCreateSubscriptionRequestModel)
    case getSubscription(header: FreeTestRequestHeader, request: FreeTestGetSubscriptionRequestModel)
}

extension FreeTestTarget: TargetType {
    var baseURL: URL {
        URL(string: ConfigManager.default.freeTestBaseURL)!
    }
    
    var path: String {
        switch self {
        case .createSubscription:
            return "/createSubscription"
        case .getSubscription:
            return "/getSubscription"
        }
    }
    
    var method: Method {
        .post
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case .createSubscription(header: _, request: let request):
            return .requestJSONEncodable(request)
        case .getSubscription(header:_, request: let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .createSubscription(header: let header, request: _):
            return header.asDictionary
        case .getSubscription(header: let header, request: _):
            return header.asDictionary
        }
    }
    
    
}
