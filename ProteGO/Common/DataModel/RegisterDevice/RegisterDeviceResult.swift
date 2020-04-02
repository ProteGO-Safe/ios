import Foundation

struct RegisterDeviceResult: Decodable {

    let registrationId: String

    let code: String?

    enum CodingKeys: String, CodingKey {
        case code
        case registrationId = "registration_id"
    }
}
