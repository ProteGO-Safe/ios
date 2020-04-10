import Foundation

//swiftlint:disable nesting
extension Constants {
    enum Realm {
        static let modelVersion: UInt64 = 1

        static let encryptionKeyLength = 64

        enum EntityKeys {
            enum ExpiringBeacon {
                static let startDate = "startDate"
            }
        }
    }
}
