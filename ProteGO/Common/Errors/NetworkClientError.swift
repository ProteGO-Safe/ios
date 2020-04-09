import Foundation

enum NetworkClientError: ProteGOError {
    case deallocated
    case networkUnavailable
    case failedToBuildUrlRequest(Error)
    case requestError(Error)
    case statusCode(Int, Data)

    var errorDescription: String? {
        switch self {
        case .deallocated:
            return "Deallocated"
        case .networkUnavailable:
            return "Network unavailable"
        case .failedToBuildUrlRequest(let error):
            return "Failed to build url request: \(error.localizedDescription)"
        case .requestError(let error):
            return "Request error: \(error.localizedDescription)"
        case .statusCode(let code, let data):
            return "Status code: \(code). Reason: \(String(data: data, encoding: .utf8) ?? "n/a")"
        }
    }
}
