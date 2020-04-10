import Foundation
import UIKit
import SwiftTweaks

extension DebugMenu {

    static var actionShowEncountersDebugScreen: Tweak<TweakAction> = {
        let description = DebugItemDescription(.encounters, group: .overview, name: "Pokaż wykryte spotkania")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            guard let rootViewController = appDelegate.window?.rootViewController else {
                return
            }

            let debugViewController: RegisteredEncountersDebugViewController =
                appDelegate.resolver.resolve(RegisteredEncountersDebugViewController.self)

            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.dismiss(animated: true) {
                    rootViewController.present(debugViewController, animated: true)
                }
            } else {
                rootViewController.present(debugViewController, animated: true)
            }

        }
        return tweak
    }()

    static var addRandomEncounter: Tweak<TweakAction> = {
        let description = DebugItemDescription(.encounters, group: .testing, name: "Dodaj losowe spotkanie")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            guard let resolver = (UIApplication.shared.delegate as? AppDelegate)?.resolver else {
                return
            }

            let encountersManager: EncountersManagerType = resolver.resolve(EncountersManagerType.self)
            let randomEncounter = Encounter.createEncounter(deviceId: BeaconId.random().getData().toHexString(),
                                                            signalStrength: Int.random(in: -100..<0),
                                                            date: Date())
            try? encountersManager.addNewEncounter(encounter: randomEncounter)
        }
        return tweak
    }()

    static var encounterItems: [TweakClusterType] = [
        actionShowEncountersDebugScreen,
        addRandomEncounter
    ]
}
