import UIKit
import SwiftTweaks
#if canImport(Firebase)
import Firebase
#endif

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, AdvertiserDelegate, ScannerDelegate {
    var window: UIWindow?
    var advertiser: Advertiser!
    var scanner: Scanner!
    var byte: UInt8 = 0

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.setupCrashlytics()

        let rootViewController = UIViewController()
        let window = self.generateWindow()

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.advertiser = BleAdvertiser(delegate: self)
        self.scanner = BleScanner(delegate: self)
        self.window = window
        return true
    }

    func tokenDataExpired(previousTokenData: (Data, Date)?) {
        NSLog("Token data expired \(String(describing: previousTokenData))")
        byte += 1
        if byte % 2 == 0 {
            self.advertiser.updateTokenData(data: Data([0xFF, byte]), expirationDate: Date(timeIntervalSinceNow: 30))
        }
    }

    func synchronizedTokenData(data: Data, rssi: Int?) {
        NSLog("Synchronized token data \(data), rssi: \(String(describing: rssi))")
    }

    private func generateWindow() -> UIWindow {
        if let tweaksEnabled = Constants.InfoKeys.tweaksEnabled.value,
            tweaksEnabled == "true" {
            return TweakWindow(frame: UIScreen.main.bounds,
                               gestureType: .shake,
                               tweakStore: DebugMenu.defaultStore)
        } else {
            return UIWindow(frame: UIScreen.main.bounds)
        }
    }

    private func setupCrashlytics() {
        #if canImport(Firebase)
        if let crashlyticsEnabled = Constants.InfoKeys.crashlyticsEnabled.value,
            crashlyticsEnabled == "true" {
            FirebaseApp.configure()
        }
        #endif
    }
}
