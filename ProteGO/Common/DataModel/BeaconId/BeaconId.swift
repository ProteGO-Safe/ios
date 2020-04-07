import Foundation

enum BeaconIdError: Error {
    case invalidStringForGeneratingBeaconId
}

/// Structure representing valid Beacon ID value.
struct BeaconId {
    private let data: Data
    private static let byteCount = 16

    init?(data: Data) {
        if data.count == BeaconId.byteCount {
            self.data = data
        } else {
            return nil
        }
    }

    func getData() -> Data {
        return data
    }

    static func random() -> BeaconId {
        // swiftlint:disable:next force_unwrapping
        return BeaconId(data: Data((0..<byteCount).map { _ in UInt8.random(in: 0...255) }))!
    }
}

extension BeaconId: Hashable, Equatable, CustomStringConvertible, Decodable {
    var description: String {
        return data.toHexString()
    }

    static func == (lhs: BeaconId, rhs: BeaconId) -> Bool {
        return lhs.data.elementsEqual(rhs.data)
    }

    public init(from decoder: Decoder) throws {
        guard let data = Data(hexString: (try decoder.singleValueContainer().decode(String.self))),
            let beacon = BeaconId(data: data) else {
                throw BeaconIdError.invalidStringForGeneratingBeaconId
        }
        self = beacon
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
}
