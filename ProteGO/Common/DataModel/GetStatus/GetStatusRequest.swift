import Foundation

struct GetStatusRequest: Encodable {

    let userId: String

    let platform: String

    let osVersion: String

    let deviceType: String

    let appVersion: String

    let apiVersion: String

    let lang: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case platform
        case osVersion = "os_version"
        case deviceType = "device_type"
        case appVersion = "app_version"
        case apiVersion = "api_version"
        case lang
    }

    init(userId: String,
         defaultParameters: DefaultRequestParameters = DefaultRequestParameters()) {
        self.userId = userId
        self.platform = defaultParameters.platform
        self.osVersion = defaultParameters.osVersion
        self.deviceType = defaultParameters.deviceType
        self.appVersion = defaultParameters.appVersion
        self.apiVersion = defaultParameters.apiVersion
        self.lang = defaultParameters.lang
    }
}
