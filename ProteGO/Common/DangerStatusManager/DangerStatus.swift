import Foundation

enum DangerStatus: String, Decodable {
    case red
    case yellow
    case green

    public init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(RawValue.self)
        guard let dangerStatus = DangerStatus(rawValue: rawValue) else {
            logger.warning("Received incorrect Danger status \(rawValue). Fallbacking to yellow")
            self = .yellow
            return
        }

        self = dangerStatus
    }
}
