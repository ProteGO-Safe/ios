import Foundation
import UIKit
import SwiftTweaks
import Valet

extension DebugMenu {

    public static var actionResetFinishedOnboardingFlag: Tweak<TweakAction> = {
        let description = DebugItemDescription(.screens, group: .onboarding, name: "Ustaw finishedOnboarding false")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            var defaultsService = DefaultsService()
            defaultsService.finishedOnboarding = false
        }
        return tweak
    }()

    public static var forceInitialRootContent: Tweak<Bool> = {
        let description = DebugItemDescription(.screens, group: .initialScreen, name: "Wymuszaj ekran początkowy")
        return Tweak<Bool>.build(with: description, default: false)
    }()

    public static var initialRootContentValue: Tweak<StringOption> = {
        return Tweak<StringOption>.stringList(
            DebugItemDescription.Collection.screens.rawValue,
            DebugItemDescription.Group.initialScreen.rawValue,
            "Ekran początkowy",
            options: [
                RootContent.onboarding.rawValue,
                RootContent.registration.rawValue,
                RootContent.dashboard.rawValue],
            defaultValue: RootContent.onboarding.rawValue)
    }()

    static var screensItems: [TweakClusterType] = [
        actionResetFinishedOnboardingFlag,
        forceInitialRootContent,
        initialRootContentValue
    ]
}
