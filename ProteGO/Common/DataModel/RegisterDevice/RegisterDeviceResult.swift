import Foundation

struct RegisterDeviceResult: Decodable {

    let registrationId: String

    let debugCode: String?

    enum CodingKeys: String, CodingKey {
        case debugCode = "code"
        case registrationId = "registration_id"
    }
}
