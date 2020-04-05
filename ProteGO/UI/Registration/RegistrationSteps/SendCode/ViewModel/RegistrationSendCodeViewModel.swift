import UIKit
import RxSwift

final class RegistrationSendCodeViewModel: RegistrationSendCodeViewModelType {

    var stepFinishedObservable: Observable<SendCodeFinishedData> {
        return model.stepFinishedObservable
    }

    private let model: RegistrationSendCodeModelType

    private let disposeBag = DisposeBag()

    init(model: RegistrationSendCodeModelType) {
        self.model = model
    }

    func bind(view: RegistrationSendCodeView) {
        view.sendCodeButtonTapEvent.subscribe(onNext: { [weak self] _ in
            let validation = Validator(type: .phoneNumber).isValid(text: view.phoneNumber)
            switch validation {
            case .success:
                self?.model.registerDevice(phoneNumber: view.phoneNumber)
            case let .failure(error):
                print(error)
                // TODO: - Handle Error
            }
        }).disposed(by: disposeBag)

        model.keyboardHeightWillChangeObservable.subscribe(onNext: { keyboardHeight in
            view.update(keyboardHeight: keyboardHeight)
        }) .disposed(by: disposeBag)
    }
}
