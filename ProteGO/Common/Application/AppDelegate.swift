import UIKit
import SwiftTweaks
import Swinject
#if canImport(Firebase)
import Firebase
#endif

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate  {
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
        self.setupOnFirstAppLaunch()
        self.setupBluetoothModule()

        let rootViewController = resolver.resolve(RootViewController.self)
        let window = self.generateWindow()

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.resolver.resolve(StatusManagerType.self)?.updateCurrentDangerStatusAndBeaconIds()
        do {
            try self.resolver.resolve(RealmCleanerType.self)?.clean()
        } catch {
            logger.error("Error cleaning old database data \(error)")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.advertiser?.setMode(.enabledAllTime)
        self.scanner?.setMode(.enabledAllTime)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.advertiser?.setMode(.enabledPartTime(
            advertisingOnTime: TimeInterval(DebugMenu.assign(DebugMenu.bluetoothAdvertiserOnTime)),
            advertisingOffTime: TimeInterval(DebugMenu.assign(DebugMenu.bluetoothAdvertiserOffTime))
        ))
        self.scanner?.setMode(.enabledPartTime(
            scanningOnTime: TimeInterval(DebugMenu.assign(DebugMenu.bluetoothScannerOnTime)),
            scanningOffTime: TimeInterval(DebugMenu.assign(DebugMenu.bluetoothScannerOffTime))
        ))
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

    private func setupOnFirstAppLaunch() {
        let defaultsService: DefaultsServiceType = resolver.resolve(DefaultsServiceType.self)
        if defaultsService.finishedFirstAppLaunch == false {
            let keychainProvider: KeychainProviderType = resolver.resolve(KeychainProviderType.self)
            keychainProvider.removeAllObjects()
            defaultsService.finishedFirstAppLaunch = true
        }
    }

    private func setupBluetoothModule() {
        let beaconIdAgent: BeaconIdAgentType = self.resolver.resolve(BeaconIdAgentType.self)
        self.advertiser = self.resolver.resolve(Advertiser.self, argument: beaconIdAgent)
        self.scanner = self.resolver.resolve(Scanner.self, argument: beaconIdAgent)
        self.advertiser?.setMode(.enabledAllTime)
        self.scanner?.setMode(.enabledAllTime)
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
            DashboardAssembly(),
            HistoryOverviewAssembly()
        ])
    }
}
