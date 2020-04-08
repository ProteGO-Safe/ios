import Foundation

struct ConfirmRegistrationResponse: Decodable {

    let userId: String

    enum CodingKeys: String, CodingKey {
        case userId
    }
}
