import Foundation
import UIKit
import SwiftTweaks

extension DebugMenu {

    static var actionShowBugfenderSessionId: Tweak<TweakAction> = {
        let description = DebugItemDescription(.general, group: .bugfender, name: "Pokaż identyfikator sesji")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
                return
            }

            let alert = UIAlertController(
                    title: "Bugfender",
                    message: logger.bugfenderSessionIdentifier,
                    preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                alert.dismiss(animated: true)
            }))

            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.dismiss(animated: true) {
                    rootViewController.present(alert, animated: true)
                }
            } else {
                rootViewController.present(alert, animated: true)
            }

        }
        return tweak
    }()

    static var performCrash: Tweak<TweakAction> = {
        let description = DebugItemDescription(.general, group: .crashlytics, name: "Wykonaj test crashlytics")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            fatalError("Test crash")
        }
        return tweak
    }()

    public static var databaseDataRetentionInterval: Tweak<Int> = {
        let description = DebugItemDescription(.general, group: .dataRetention,
                                               name: "Okres przetrzymywania danych")
        return Tweak<Int>.build(with: description,
                                default: Constants.Encounters.defaultDatabaseDataRetentionInterval, min: 0)
    }()

    static var generalItems: [TweakClusterType] = [
        actionShowBugfenderSessionId,
        performCrash,
        databaseDataRetentionInterval
    ]
}
