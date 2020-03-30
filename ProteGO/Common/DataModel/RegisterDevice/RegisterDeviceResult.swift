import Foundation

struct RegisterDeviceResult: Decodable {

    let registrationId: String

    enum CodingKeys: String, CodingKey {
        case registrationId = "registration_id"
    }
}
