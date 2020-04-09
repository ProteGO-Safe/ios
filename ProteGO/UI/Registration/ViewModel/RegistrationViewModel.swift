import Foundation
import RxSwift
import RxCocoa

final class RegistrationViewModel: RegistrationViewModelType {

    var currentStepObservable: Observable<RegistrationStep> {
        return model.currentStepOnservable
    }

    var goBackObservable: Observable<Void> {
        return model.goBackObservable
    }

    var registrationFinishedObservable: Observable<Void> {
        return model.registrationFinishedObservable
    }

    var dismissKeyboardObservable: Observable<Void> {
        return Observable.merge(
            dismissKeyboardSubject.asObservable(),
            model.requestInProgressObservable.map({ _ in return () }))
    }

    var requestInProgressDriver: Driver<Bool> {
        return model.requestInProgressObservable
            .asDriver(onErrorJustReturn: false)
    }

    private let dismissKeyboardSubject = PublishSubject<Void>()

    private let model: RegistrationModelType

    private let disposeBag = DisposeBag()

    init(model: RegistrationModelType) {
        self.model = model
    }

    func setInitialStep() {
        model.setInitialStep()
    }

    func bind(view: RegistrationView) {
        view.backButtonTapEvent.subscribe(onNext: { [weak self] _ in
            self?.model.previousStep()
        }).disposed(by: disposeBag)

        view.tapAnywhereEvent.subscribe(onNext: { [weak self] _ in
            self?.dismissKeyboardSubject.onNext(())
        }).disposed(by: disposeBag)

        requestInProgressDriver.drive(view.requestInProgressBinder).disposed(by: disposeBag)
    }

    func bind(sendCodeViewController: RegistrationSendCodeViewController) {
        sendCodeViewController.stepFinishedObservable
            .subscribe(onNext: { [weak self] finishedData in
                self?.model.sendCodeStepFinished(finishedData: finishedData)
        }).disposed(by: disposeBag)

        sendCodeViewController.requestInProgressObservable
            .subscribe(onNext: { [weak self] inProgress in
                self?.model.requestInProgress(inProgress)
            }).disposed(by: disposeBag)
    }

    func bind(verifyCodeViewController: RegistrationVerifyCodeViewController) {
        verifyCodeViewController.stepFinishedObservable
            .subscribe(onNext: { [weak self] _ in
                self?.model.verifyCodeStepFinished()
            }).disposed(by: disposeBag)

        verifyCodeViewController.requestInProgressObservable
            .subscribe(onNext: { [weak self] inProgress in
                self?.model.requestInProgress(inProgress)
            }).disposed(by: disposeBag)
    }
}
