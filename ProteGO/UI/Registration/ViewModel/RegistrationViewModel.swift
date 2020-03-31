import Foundation
import RxSwift

final class RegistrationViewModel: RegistrationViewModelType {

    var currentStepOnservable: Observable<RegistrationStep> {
        return model.currentStepOnservable
    }

    var goBackObservable: Observable<Void> {
        return model.goBackObservable
    }

    var registrationFinishedObservable: Observable<Void> {
        return model.registrationFinishedObservable
    }

    var dismissKeyboardObservable: Observable<Void> {
        return dismissKeyboardSubject.asObservable()
    }

    private let dismissKeyboardSubject = PublishSubject<Void>()

    private let model: RegistrationModelType

    private let disposeBag = DisposeBag()

    init(model: RegistrationModelType) {
        self.model = model
    }

    func bind(view: RegistrationView) {
        view.backButtonTapEvent.subscribe(onNext: { [weak self] _ in
            self?.model.previousStep()
        }).disposed(by: disposeBag)

        view.tapAnywhereEvent.subscribe(onNext: { [weak self] _ in
            self?.dismissKeyboardSubject.onNext(())
        }).disposed(by: disposeBag)
    }

    func bind(sendCodeViewController: SendCodeViewController) {

        sendCodeViewController.stepFinishedObservable
            .subscribe(onNext: { [weak self] stepFinishedData in
                self?.model.sendCodeStepFinished(phoneNumber: stepFinishedData.phoneNumber)
        }).disposed(by: disposeBag)
    }

    func bind(verifyCodeViewController: VerifyCodeViewController) {
        verifyCodeViewController.stepFinishedObservable
            .subscribe(onNext: { [weak self] _ in
                self?.model.verifyCodeStepFinished()
            }).disposed(by: disposeBag)
    }
}
