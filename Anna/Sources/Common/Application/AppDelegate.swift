import UIKit
import Swinject

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var assembler: Assembler?

    lazy var resolver: Resolver = {
        guard let resolver = (assembler?.resolver as? Container)?.synchronize() else {
            fatalError("Assembler not configured")
        }
        return resolver
    }()

    var locationTrackingManager: LocationTrackingManagerType?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupDependencyInjection()

        locationTrackingManager = resolver.resolve(LocationTrackingManagerType.self)

        let rootViewController: RootViewController = resolver.resolve(RootViewController.self)
        let window = UIWindow(frame: UIScreen.main.bounds)

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("App did become active")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("App will resign active")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("App will enter foreground")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App did enter background")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("App will teminate")
        locationTrackingManager?.monitorLastLocationRegion()
    }

    private func setupDependencyInjection() {
        assembler = Assembler([
            LocationTrackingAssembly(),
            RootViewControllerAssembly()
        ])
    }
}

