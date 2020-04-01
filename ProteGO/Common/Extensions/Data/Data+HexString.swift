import Foundation

private let hexDigits = Array("0123456789ABCDEF".utf8)

extension Data {
    func toHexString() -> String {
        var chars: [UInt8] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(cString: chars)
    }
}
