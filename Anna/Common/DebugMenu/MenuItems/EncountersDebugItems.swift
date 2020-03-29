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

    public static var oldEncountersRemovalInterval: Tweak<Int> = {
        let description = DebugItemDescription(.encounters, group: .overview,
                                               name: "Najstarsze spotkania")
        return Tweak<Int>.build(with: description, default: Constants.Encounters.defaultOldEncountersRemovalInterval, min: 0)
    }()

    static var addRandomEncounter: Tweak<TweakAction> = {
        let description = DebugItemDescription(.encounters, group: .testing, name: "Dodaj losowe spotkanie")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            guard let resolver = (UIApplication.shared.delegate as? AppDelegate)?.resolver else {
                return
            }

            let encountersManager: EncountersManagerType = resolver.resolve(EncountersManagerType.self)
            let randomEncounter = Encounter.createEncounter(deviceId: String.randomString(length: 10),
                                                            signalStrength: Int.random(in: 0..<100),
                                                            date: Date())
            try? encountersManager.addNewEncounter(encounter: randomEncounter)
        }
        return tweak
    }()

    static var deleteOldEncounters: Tweak<TweakAction> = {
        let description = DebugItemDescription(.encounters, group: .testing, name: "Usuń stare spotkania")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            guard let resolver = (UIApplication.shared.delegate as? AppDelegate)?.resolver else {
                return
            }

            let encountersManager: EncountersManagerType = resolver.resolve(EncountersManagerType.self)
            let interval = DebugMenu.assign(DebugMenu.oldEncountersRemovalInterval)
            let date = Date(timeIntervalSinceNow: TimeInterval(-interval))
            try? encountersManager.deleteAllEncountersOlderThan(date: date)
        }
        return tweak
    }()

    static var encounterItems: [TweakClusterType] = [
        actionShowEncountersDebugScreen,
        oldEncountersRemovalInterval,
        addRandomEncounter,
        deleteOldEncounters
    ]
}
