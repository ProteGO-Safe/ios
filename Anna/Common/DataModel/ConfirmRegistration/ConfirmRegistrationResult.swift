import Foundation

struct ConfirmRegistrationResult: Decodable {

    let userId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}
