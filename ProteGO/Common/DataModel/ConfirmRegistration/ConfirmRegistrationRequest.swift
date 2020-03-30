import Foundation

struct ConfirmRegistrationRequest: Encodable {

    let code: String

    let registrationId: String

    let platform: String

    let osVersion: String

    let deviceType: String

    let appVersion: String

    let apiVersion: String

    let lang: String

    enum CodingKeys: String, CodingKey {
        case code
        case registrationId = "registration_id"
        case platform
        case osVersion
        case deviceType
        case appVersion
        case apiVersion
        case lang
    }

    init(code: String,
         registrationId: String,
         defaultParameters: DefaultRequestParameters = DefaultRequestParameters()) {
        self.code = code
        self.registrationId = registrationId
        self.platform = defaultParameters.platform
        self.osVersion = defaultParameters.osVersion
        self.deviceType = defaultParameters.deviceType
        self.appVersion = defaultParameters.appVersion
        self.apiVersion = defaultParameters.apiVersion
        self.lang = defaultParameters.lang
    }
}
