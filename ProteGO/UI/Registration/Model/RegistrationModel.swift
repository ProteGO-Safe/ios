import Foundation
import RxSwift

enum RegistrationStep {
    case sendCode, verifyCode(phoneNumber: String)
}

final class RegistrationModel: RegistrationModelType {

    var currentStepOnservable: Observable<RegistrationStep> {
        return currentStepSubject.asObservable()
    }

    var goBackObservable: Observable<Void> {
        return goBackSubject.asObservable()
    }

    var registrationFinishedObservable: Observable<Void> {
        return registrationFinishedSubject.asObservable()
    }

    var requestInProgressObservable: Observable<Bool> {
        return requestInProgressSubject.asObservable()
    }

    private var currentStep: RegistrationStep = .sendCode {
        didSet {
            currentStepSubject.onNext(currentStep)
        }
    }

    private lazy var currentStepSubject = BehaviorSubject<RegistrationStep>(value: currentStep)

    private let goBackSubject = PublishSubject<Void>()

    private let registrationFinishedSubject = PublishSubject<Void>()

    private let requestInProgressSubject = BehaviorSubject<Bool>(value: false)

    func setInitialStep() {
        currentStep = .sendCode
    }

    func previousStep() {
        switch currentStep {
        case .sendCode:
            goBackSubject.onNext(())
        case .verifyCode:
            currentStep = .sendCode
        }
    }

    func sendCodeStepFinished(finishedData: SendCodeFinishedData) {
        guard case .sendCode = currentStep else {
            return
        }
        switch finishedData {
        case .sendCode(let phoneNumber):
            currentStep = .verifyCode(phoneNumber: phoneNumber)
        case .registerWithoutPhoneNumber:
            registrationFinishedSubject.onNext(())
        }
    }

    func verifyCodeStepFinished() {
        guard case .verifyCode = currentStep else {
            return
        }
        registrationFinishedSubject.onNext(())
    }

    func requestInProgress(_ inProgress: Bool) {
        requestInProgressSubject.onNext(inProgress)
    }
}
