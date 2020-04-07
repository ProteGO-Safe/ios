import Foundation

extension String {
    func prefix(withLengthRatio ratio: Double) -> String {
        return String(self.prefix(Int(floor(Double(self.count) * ratio))))
    }
}
