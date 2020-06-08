//
//  ExposureKeysTarget.swift
//  safesafe
//

import Moya

@available(iOS 13.5, *)
enum ExposureKeysTarget {
    case auth(TemporaryExposureKeysAuthData)
    case post(TemporaryExposureKeysData)
    case get
    case download(fileName: String, destination: DownloadDestination)
}

@available(iOS 13.5, *)
extension ExposureKeysTarget: TargetType {
    
    var baseURL: URL {
        switch self {
        case .get, .download:
            return URL(string: ConfigManager.default.enStorageURL)!
        case .auth:
            return URL(string: ConfigManager.default.enGatBaseURL)!
        case .post:
            return URL(string: ConfigManager.default.enUdkBaseURL)!
        }
        
    }
    
    var path: String {
        switch self {
        case .auth:
            return "getAccessToken"
            
        case .post:
            return "uploadDiagnosisKeys"
            
        case .get:
            return "/index.txt"
            
        case let .download(fileName, _):
            return "/\(fileName)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .auth, .post:
            return .post
        case .get, .download:
            return .get
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
            
        case .get:
            return .requestPlain
            
        case let .download(_, destination):
            return .downloadDestination(destination)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
