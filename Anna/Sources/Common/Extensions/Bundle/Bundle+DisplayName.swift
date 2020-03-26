import Foundation

extension Bundle {

    var displayName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }
}
