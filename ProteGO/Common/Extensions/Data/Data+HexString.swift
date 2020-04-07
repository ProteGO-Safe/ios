import Foundation

private let hexDigits = Array("0123456789ABCDEF".utf8)

extension Data {
    func toHexString() -> String {
        var chars: [UInt8] = []
        chars.reserveCapacity(2 * count + 1)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        chars.append(0)
        return String(cString: chars)
    }

    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}
