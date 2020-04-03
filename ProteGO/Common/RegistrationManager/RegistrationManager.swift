import Foundation
import Valet
import RxSwift

enum RegistrationManagerError: Error {
    case failedToRetrieveRegistrationId
}

final class RegistrationManager: RegistrationManagerType {

    var isUserRegistered: Bool {
        return userId != nil
    }

    var isUserRegisteredObservable: Observable<Bool> {
        return userIdSubject.asObservable()
            .map { $0 != nil }
    }

    private(set) var userId: String? {
        get {
            return valet.string(forKey: Constants.KeychainKeys.userIdKey)
        }
        set {
            guard let newValue = newValue else {
                valet.removeObject(forKey: Constants.KeychainKeys.userIdKey)
                return
            }
            valet.set(string: newValue, forKey: Constants.KeychainKeys.userIdKey)
            userIdSubject.onNext(newValue)
        }
    }

    private(set) var registrationId: String? {
        get {
            return valet.string(forKey: Constants.KeychainKeys.registrationIdKey)
        }
        set {
            guard let newValue = newValue else {
                valet.removeObject(forKey: Constants.KeychainKeys.registrationIdKey)
                return
            }
            valet.set(string: newValue, forKey: Constants.KeychainKeys.registrationIdKey)
        }
    }

    private(set) var debugRegistrationCode: String?

    private let userIdSubject = PublishSubject<String?>()

    private let valet: Valet

    private let disposeBag = DisposeBag()

    init(valet: Valet) {
        self.valet = valet
    }

    func register(registrationId: String) {
        logger.debug("Saved registration id")
        self.registrationId = registrationId
    }

    func confirmRegistration(userId: String) {
        logger.debug("Saved user id")
        self.userId = userId
        registrationId = nil
    }

    func invalidateUserId() {
        logger.debug("Removed user id")
        userId = nil
    }

    func set(debugRegistrationCode: String?) {
        logger.debug("Saved registration code")
        self.debugRegistrationCode = debugRegistrationCode

    }
}
