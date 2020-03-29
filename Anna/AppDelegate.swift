import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, AdvertiserDelegate, ScannerDelegate {
    var window: UIWindow?
    var advertiser: Advertiser!
    var scanner: Scanner!
    var byte: UInt8 = 0

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let rootViewController = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)

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
}

