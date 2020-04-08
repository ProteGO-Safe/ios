import Foundation

struct SendHistoryResponse: Decodable {

    let status: String

    enum CodingKeys: String, CodingKey {
        case status
    }
}
