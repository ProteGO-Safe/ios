//
//  ExposureKeysTarget.swift
//  safesafe
//

import Moya

@available(iOS 13.5, *)
enum ExposureKeysTarget {
    case auth(TemporaryExposureKeysAuthData)
    case post(TemporaryExposureKeysData)
//    case download
}

@available(iOS 13.5, *)
extension ExposureKeysTarget: TargetType {
    
    var baseURL: URL {
        return URL(string: ConfigManager.default.enBaseURL)!
    }
    
    var path: String {
        switch self {
        case .auth:
            return "getAccessToken"
            
        case .post:
            return "uploadDiagnosisKeys"
        }
    }
    
    var method: Method {
        switch self {
        case .auth, .post:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .auth(let temporaryExposureKeysAuthData):
            return .requestJSONEncodable(temporaryExposureKeysAuthData)
            
        case .post(let temporaryExposureKeys):
            return .requestJSONEncodable(temporaryExposureKeys)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
