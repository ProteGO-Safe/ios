import Foundation

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

extension BeaconId: Hashable, Equatable, CustomStringConvertible {
    var description: String {
        return data.toHexString()
    }

    static func == (lhs: BeaconId, rhs: BeaconId) -> Bool {
        return lhs.data.elementsEqual(rhs.data)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
}
