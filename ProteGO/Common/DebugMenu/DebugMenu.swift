import Foundation
import UIKit
import SwiftTweaks

struct DebugItemDescription {
    enum Collection: String {
        case general = "Ogólne"
        case encounters = "Spotkania"
        case bluetooth = "Bluetooth"
    }

    enum Group: String {
        case bugfender = "Bugfender"
        case crashlytics = "Crashlytics"
        case overview = "Podsumowanie"
        case testing = "Testowanie"
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

        return TweakStore(
            tweaks: allTweaks,
            enabled: true
        )
    }()
}
