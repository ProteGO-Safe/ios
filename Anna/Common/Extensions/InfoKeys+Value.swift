import Foundation

extension Constants.InfoKeys {
    var value: String? {
        return Bundle(for: AppDelegate.self)
            .object(forInfoDictionaryKey: self.rawValue) as? String
    }
}
