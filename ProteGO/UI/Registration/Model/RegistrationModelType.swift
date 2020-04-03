import Foundation
import RxSwift

protocol RegistrationModelType {

    var currentStepOnservable: Observable<RegistrationStep> { get }

    var goBackObservable: Observable<Void> { get }

    var registrationFinishedObservable: Observable<Void> { get }

    func setInitialStep()

    func previousStep()

    func sendCodeStepFinished(phoneNumber: String)

    func verifyCodeStepFinished()
}
