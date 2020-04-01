import UIKit
import SwiftTweaks
import Swinject
#if canImport(Firebase)
import Firebase
#endif

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, AdvertiserDelegate  {
    lazy var resolver: Resolver = {
        guard let resolver = (assembler?.resolver as? Container)?.synchronize() else {
            fatalError("Assembler not configured")
        }
        return resolver
    }()

    var advertiser: Advertiser?
    var scanner: Scanner?
    var assembler: Assembler?
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.setupDependencyInjection()
        self.setupCrashlytics()
        self.setupBluetoothModule()

        let rootViewController = resolver.resolve(RootViewController.self)
        let window = self.generateWindow()

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.advertiser?.setMode(.EnabledAllTime)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.advertiser?.setMode(.EnabledPartTime(advertisingOnTime: 10, advertisingOffTime: 30))
    }

    var count: UInt8 = 0
    func beaconIdExpired(previousBeaconId: (BeaconId, Date)?) {
        let advertiser: Advertiser = self.resolver.resolve(Advertiser.self, argument: self as AdvertiserDelegate)
        count += 1

        if let beaconId = BeaconId(data: Data([count, 0x01, 0x02, 0x03,
                                               0x04, 0x05, 0x06, 0x07,
                                               0x08, 0x09, 0x10, 0x11,
                                               0x12, 0x13, 0x14, 0x15])) {
            advertiser.updateBeaconId(beaconId: beaconId, expirationDate: Date(timeIntervalSinceNow: 30))
        }
    }

    func synchronizedBeaconId(beaconId: BeaconId, rssi: Int?) {
        logger.info("*** synchronized \(beaconId) with rssi: \(String(describing: rssi))")
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

    private func setupBluetoothModule() {
        self.advertiser = self.resolver.resolve(Advertiser.self, argument: self as AdvertiserDelegate)
        self.advertiser?.setMode(.EnabledAllTime)
        let encountersManager: EncountersManagerType = self.resolver.resolve(EncountersManagerType.self)
        self.scanner = self.resolver.resolve(Scanner.self, argument: encountersManager as ScannerDelegate)
    }

    private func setupCrashlytics() {
        #if canImport(Firebase)
        if let crashlyticsEnabled = Constants.InfoKeys.crashlyticsEnabled.value,
            crashlyticsEnabled == "true" {
            FirebaseApp.configure()
        }
        #endif
    }

    private func setupDependencyInjection() {
        assembler = Assembler([
            GeneralAssembly(),
            DebugAssembly(),
            BluetoothAssembly(),
            NetworkingAssembly(),
            RootAssembly(),
            OnboardingAssembly(),
            RegistrationAssembly(),
            DashboardAssembly()
        ])
    }
}
