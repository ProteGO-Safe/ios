import Foundation
import UIKit
import SwiftTweaks
import Valet

extension DebugMenu {

    public static var registrationDebugNoSms: Tweak<Bool> = {
        let description = DebugItemDescription(.registration, group: .oneTimeCode, name: "Rejestracja dev bez SMSa")
        let defaultValue: Bool
        if let environmentString = Constants.InfoKeys.environment.value,
            let environment = Constants.Environment(rawValue: environmentString) {
            defaultValue = environment == .development
        } else {
            defaultValue = false
        }
        return Tweak<Bool>.build(with: description, default: defaultValue)
    }()

    public static var actionInvalidateUserId: Tweak<TweakAction> = {
        let description = DebugItemDescription(.registration, group: .userId, name: "Unieważnij identyfikator użytkownika")
        let tweak = Tweak<TweakAction>.build(with: description)
        tweak.addClosure {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let resolver = appDelegate.resolver

            let registrationManager: RegistrationManagerType = resolver.resolve(RegistrationManagerType.self)
            registrationManager.invalidateUserId()
        }
        return tweak
    }()

    static var registrationItems: [TweakClusterType] = [
        registrationDebugNoSms,
        actionInvalidateUserId
    ]
}
