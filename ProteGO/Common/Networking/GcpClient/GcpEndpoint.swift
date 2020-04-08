import Foundation

enum GcpEndpoint {

    private static let baseUrl = Constants.InfoKeys.apiBaseUrl.value ?? ""

    case registerDevice(RegisterDeviceRequest)

    case confirmRegistration(ConfirmRegistrationRequest)

    case getStatus(GetStatusRequest)

    case sendHistory(SendHistoryRequest)

    var networkRequest: NetworkRequest {
        return NetworkRequest(httpMethod: httpMethod, url: url, headers: headers, queryParameters: nil, body: body)
    }

    private var httpMethod: NetworkRequest.HttpMethod {
        switch self {
        case .registerDevice, .confirmRegistration, .getStatus, .sendHistory:
            return .post
        }
    }

    private var url: String {
        return Self.baseUrl + pathComponent
    }

    private var pathComponent: String {
        switch self {
        case .registerDevice:
            return "/register"
        case .confirmRegistration:
            return "/confirm_registration"
        case .getStatus:
            return "/get_status"
        case .sendHistory:
            return "/send_encounters"
        }
    }

    private var headers: [String: String]? {
        switch self {
        case .registerDevice, .confirmRegistration, .getStatus, .sendHistory:
            return ["Content-Type": "application/json"]
        }
    }

    private var body: Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        switch self {
        case .registerDevice(let body):
            return try? encoder.encode(body)
        case .confirmRegistration(let body):
            return try? encoder.encode(body)
        case .getStatus(let body):
            encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddHH)
            return try? encoder.encode(body)
        case .sendHistory(let body):
            encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddHH)
            return try? encoder.encode(body)
        }
    }
}
