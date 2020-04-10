import Foundation

enum GcpClientError: ProteGOError {
    case failedToDecodeResponseData(Error)
    case failedToBuildRequest

    var errorDescription: String? {
        switch self {
        case .failedToDecodeResponseData(let error):
            return "Failed to decode response data: \(error.localizedDescription)"
        case .failedToBuildRequest:
            return "Failed to build request"
        }
    }
}
