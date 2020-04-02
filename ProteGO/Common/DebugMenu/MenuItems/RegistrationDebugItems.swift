import Foundation
import UIKit
import SwiftTweaks
import Valet

extension DebugMenu {

    public static var registrationDebugNoSms: Tweak<Bool> = {
        let description = DebugItemDescription(.registration, group: .oneTimeCode, name: "Rejestracja dev bez SMSa")
        return Tweak<Bool>.build(with: description, default: false)
    }()

    public static var actionInvalidateUserId: Tweak<TweakAction> = {
        let description = DebugItemDescription(.registration, group: .userId, name: "Unieważnij identyfikator użytkownika")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            //swiftlint:disable force_unwrapping
            let sandboxId = Identifier(nonEmpty: Constants.ValetSandboxIds.secrets)!
            let valet = Valet.valet(with: sandboxId, accessibility: .afterFirstUnlock)
            let registrationManager = RegistrationManager(valet: valet)
            registrationManager.invalidateUserId()
        }
        return tweak
    }()

    static var registrationItems: [TweakClusterType] = [
        registrationDebugNoSms,
        actionInvalidateUserId
    ]
}
