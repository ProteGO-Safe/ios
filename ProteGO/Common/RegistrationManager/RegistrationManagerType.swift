import Foundation
import RxSwift

protocol RegistrationManagerType {

    var isUserRegistered: Bool { get }

    var isUserRegisteredObservable: Observable<Bool> { get }

    var userId: String? { get }

    var registrationId: String? { get }

    var debugRegistrationCode: String? { get }

    func register(registrationId: String)

    func confirmRegistration(userId: String)

    func invalidateUserId()

    func set(debugRegistrationCode: String?)
}
