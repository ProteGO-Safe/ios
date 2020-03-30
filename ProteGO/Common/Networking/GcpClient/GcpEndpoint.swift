import Foundation

enum GcpEndpoint {

    private static let baseUrl = Constants.InfoKeys.apiBaseUrl.value ?? ""

    case registerDevice(RegisterDeviceRequest)

    case confirmRegistration(ConfirmRegistrationRequest)

    var networkRequest: NetworkRequest {
        return NetworkRequest(httpMethod: httpMethod, url: url, headers: headers, queryParameters: nil, body: body)
    }

    private var httpMethod: NetworkRequest.HttpMethod {
        switch self {
        case .registerDevice:
            return .post
        case .confirmRegistration:
            return .post
        }
    }

    private var url: String {
        return Self.baseUrl + pathComponent
    }

    private var pathComponent: String {
        switch self {
        case .registerDevice:
            return "/register_device_PRODUCTION"
        case .confirmRegistration:
            return "/confirm_registration"
        }
    }

    private var headers: [String: String]? {
        switch self {
        case .registerDevice, .confirmRegistration:
            return ["Content-Type": "application/json"]
        }
    }

    private var body: Data? {
        switch self {
        case .registerDevice(let body):
            return try? JSONEncoder().encode(body)
        case .confirmRegistration(let body):
            return try? JSONEncoder().encode(body)
        }
    }
}
