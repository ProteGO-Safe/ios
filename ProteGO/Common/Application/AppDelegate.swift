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

    var assembler: Assembler?
    var window: UIWindow?
    var byte: UInt8 = 0

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
        let _: Advertiser = self.resolver.resolve(Advertiser.self, argument: self as AdvertiserDelegate)

        let encountersManager: EncountersManagerType = self.resolver.resolve(EncountersManagerType.self)
        let _: Scanner = self.resolver.resolve(Scanner.self, argument: encountersManager as ScannerDelegate)
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
