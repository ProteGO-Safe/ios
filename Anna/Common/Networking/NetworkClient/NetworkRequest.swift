import Foundation

struct NetworkRequest {

    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }

    let httpMethod: HttpMethod

    let url: String

    let queryParameters: [String: String]?

    let body: Data?
}
