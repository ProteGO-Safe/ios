import UIKit
import RxSwift

final class RegistrationVerifyCodeViewModel: RegistrationVerifyCodeViewModelType {

    var stepFinishedObservable: Observable<Void> {
        return model.stepFinishedObservable
    }

    var requestInProgressObservable: Observable<Bool> {
        return model.requestInProgressObservable
    }

    private let model: RegistrationVerifyCodeModelType

    private let disposeBag = DisposeBag()

    init(model: RegistrationVerifyCodeModelType) {
        self.model = model
    }

    func bind(view: RegistrationVerifyCodeView) {
        view.verifyCodeButtonTapEvent.subscribe(onNext: { [weak self] _ in
            self?.confirmRegistration(code: view.code)
        }).disposed(by: disposeBag)

        model.keyboardHeightWillChangeObservable.subscribe(onNext: { keyboardHeight in
            view.update(keyboardHeight: keyboardHeight)
        }) .disposed(by: disposeBag)
    }

    func confirmRegistration(code: String) {
        model.confirmRegistration(code: code)
    }
}
