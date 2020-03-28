import Foundation
import UIKit
import SwiftTweaks

struct DebugItemDescription {
    enum Collection: String {
        case general = "Ogólne"
    }

    enum Group: String {
        case bugfender = "Bugfender"
        case crashlytics = "Crashlytics"
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

public class DebugMenu: TweakLibraryType {
    public static let defaultStore: TweakStore = {
        var allTweaks = [TweakClusterType]()

        allTweaks.append(contentsOf: DebugMenu.generalItems)

        return TweakStore(
            tweaks: allTweaks,
            enabled: true
        )
    }()
}
