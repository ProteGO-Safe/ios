import Foundation

enum DangerStatus: String, Decodable {
    case red
    case yellow
    case green

    public init(from decoder: Decoder) throws {
        self = try DangerStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .yellow
    }
}
