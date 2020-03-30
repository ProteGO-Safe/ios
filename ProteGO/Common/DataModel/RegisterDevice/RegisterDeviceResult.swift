import Foundation

struct RegisterDeviceResult: Decodable {

    let code: String

    let registrationId: String

    enum CodingKeys: String, CodingKey {
        case code
        case registrationId = "registration_id"
    }
}
