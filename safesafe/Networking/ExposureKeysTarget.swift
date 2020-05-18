//
//  ExposureKeysTarget.swift
//  safesafe
//

import Moya

@available(iOS 13.5, *)
enum ExposureKeysTarget {
//    case download
    case post(TemporaryExposureKeys)
}

@available(iOS 13.5, *)
extension ExposureKeysTarget: TargetType {
    
    var baseURL: URL {
        return URL(string: ConfigManager.default.enBaseURL)!
    }
    
    var path: String {
        switch self {
        case .post:
            return "uploadDiagnosisKeys"
        }
    }
    
    var method: Method {
        switch self {
        case .post:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
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
