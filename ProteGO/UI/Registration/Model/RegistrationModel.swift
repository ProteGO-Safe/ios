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

    private var currentStep: RegistrationStep = .sendCode {
        didSet {
            currentStepSubject.onNext(currentStep)
        }
    }

    private lazy var currentStepSubject = BehaviorSubject<RegistrationStep>(value: currentStep)

    private let goBackSubject = PublishSubject<Void>()

    private let registrationFinishedSubject = PublishSubject<Void>()

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

    func sendCodeStepFinished(phoneNumber: String) {
        guard case .sendCode = currentStep else {
            return
        }
        currentStep = .verifyCode(phoneNumber: phoneNumber)
    }

    func verifyCodeStepFinished() {
        guard case .verifyCode = currentStep else {
            return
        }
        registrationFinishedSubject.onNext(())
    }
}
