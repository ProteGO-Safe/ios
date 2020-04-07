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
        case userId
        case platform
        case osVersion
        case deviceType
        case appVersion
        case apiVersion
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
