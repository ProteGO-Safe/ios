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

    func tokenDataExpired(previousTokenData: (Data, Date)?) {
        let advertiser: Advertiser = self.resolver.resolve(Advertiser.self, argument: self as AdvertiserDelegate)
        logger.debug("Token data expired \(String(describing: previousTokenData))")
        advertiser.updateTokenData(data: Data([0xFF, byte]), expirationDate: Date(timeIntervalSinceNow: 30))
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
