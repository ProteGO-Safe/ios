import UIKit

struct DefaultRequestParameters {

    let platform = "ios"

    let osVersion = UIDevice.current.systemVersion

    let deviceType = UIDevice.current.name

    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

    let apiVersion = Constants.Networking.apiVersion

    let lang = NSLocale.autoupdatingCurrent.languageCode ?? ""
}
