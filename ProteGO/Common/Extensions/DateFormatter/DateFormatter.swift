import Foundation

extension DateFormatter {
  static let yyyyMMddHHmmss: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMddHHmmss"
    formatter.timeZone = TimeZone(identifier: "CET")
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
