import UIKit
import Firebase
import FirebaseCrashlytics

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

         self.setupCrashlytics()

        let rootViewController = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window

        return true
    }

    private func setupCrashlytics() {
        if let crashlyticsEnabled = Constants.InfoKeys.crashlyticsEnabled.value,
            crashlyticsEnabled == "true" {
            FirebaseApp.configure()
        }
    }

}
