import Foundation
import RxSwift

protocol RegistrationModelType {

    var currentStepOnservable: Observable<RegistrationStep> { get }

    var goBackObservable: Observable<Void> { get }

    var registrationFinishedObservable: Observable<Void> { get }

    var requestInProgressObservable: Observable<Bool> { get }

    func setInitialStep()

    func previousStep()

    func sendCodeStepFinished(finishedData: SendCodeFinishedData)

    func verifyCodeStepFinished()

    func requestInProgress(_ inProgress: Bool)
}
