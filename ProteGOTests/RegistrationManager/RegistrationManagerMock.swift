import Foundation
import RxSwift
@testable import ProteGO

final class RegistrationManagerMock: RegistrationManagerType {
    var isUserRegistered = false

    var isUserRegisteredObservable: Observable<Bool> {
        return self.isUserRegisteredSubject
    }

    var userId: String?

    var registrationId: String?

    var debugRegistrationCode: String?

    let isUserRegisteredSubject = PublishSubject<Bool>()

    func register(registrationId: String) {
    }

    func confirmRegistration(userId: String) {
    }

    func invalidateUserId() {
    }

    func set(debugRegistrationCode: String?) {
    }
}
