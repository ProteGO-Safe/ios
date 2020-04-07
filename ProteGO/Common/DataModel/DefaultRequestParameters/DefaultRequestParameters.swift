import UIKit
import DeviceGuru

struct DefaultRequestParameters {

    let platform = "ios"

    let osVersion = UIDevice.current.systemVersion

    let deviceType = DeviceGuru().hardwareSimpleDescription() ?? "unknown"

    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

    let apiVersion = Constants.Networking.apiVersion

    let lang = NSLocale.autoupdatingCurrent.languageCode ?? ""
}
