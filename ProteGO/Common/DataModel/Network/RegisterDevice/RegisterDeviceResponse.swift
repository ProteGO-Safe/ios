import Foundation

struct RegisterDeviceResponse: Decodable {

    let registrationId: String

    let debugCode: String?

    enum CodingKeys: String, CodingKey {
        case debugCode = "code"
        case registrationId
    }
}
