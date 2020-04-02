import Foundation
import UIKit
import SwiftTweaks

extension DebugMenu {

    public static var forceDangerStatus: Tweak<Bool> = {
        let description = DebugItemDescription(.dangerStatus, group: .testing, name: "Wymuszaj status")
        return Tweak<Bool>.build(with: description, default: false)
    }()

    public static var forceDangerStatusValue: Tweak<StringOption> = {
        return Tweak<StringOption>.stringList(
            DebugItemDescription.Collection.dangerStatus.rawValue,
            DebugItemDescription.Group.testing.rawValue,
            "Wymuszony status",
            options: [
                DangerStatus.green.rawValue,
                DangerStatus.yellow.rawValue,
                DangerStatus.red.rawValue],
            defaultValue: DangerStatus.yellow.rawValue)
    }()

    static var dangerStatusItems: [TweakClusterType] = [
        forceDangerStatus,
        forceDangerStatusValue
    ]
}
