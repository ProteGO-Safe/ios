import Foundation
import UIKit
import SwiftTweaks

struct DebugItemDescription {
    enum Collection: String {
        case general = "Ogólne"
        case encounters = "Spotkania"
        case bluetooth = "Bluetooth"
        case screens = "Ekrany"
        case registration = "Rejestracja"
    }

    enum Group: String {
        case bugfender = "Bugfender"
        case crashlytics = "Crashlytics"
        case overview = "Podsumowanie"
        case testing = "Testowanie"
        case onboarding = "Onboarding"
        case userId = "Identyfikator użytkownika"
        case initialScreen = "Ekran początkowy"
        case oneTimeCode = "Kod jednorazowy"
        case dataRetention = "Przechowywanie danych"
    }

    let collection: Collection
    let group: Group
    let name: String

    init(_ collection: Collection, group: Group, name: String) {
        self.collection = collection
        self.group = group
        self.name = name
    }
}

class DebugMenu: TweakLibraryType {
    static let defaultStore: TweakStore = {
        var allTweaks = [TweakClusterType]()

        allTweaks.append(contentsOf: DebugMenu.generalItems)
        allTweaks.append(contentsOf: DebugMenu.encounterItems)
        allTweaks.append(contentsOf: DebugMenu.bluetoothItems)
        allTweaks.append(contentsOf: DebugMenu.registrationItems)
        allTweaks.append(contentsOf: DebugMenu.screensItems)

        return TweakStore(
            tweaks: allTweaks,
            enabled: true
        )
    }()
}
