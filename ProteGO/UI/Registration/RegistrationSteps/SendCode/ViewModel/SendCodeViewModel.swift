import Foundation
import RxSwift

final class SendCodeViewModel: SendCodeViewModelType {

    var stepFinishedObservable: Observable<Void> {
        return model.stepFinishedObservable
    }

    private let model: SendCodeModelType

    private let disposeBag = DisposeBag()

    init(model: SendCodeModelType) {
        self.model = model
    }

    func bind(view: SendCodeView) {
        view.sendCodeButtonTapEvent.subscribe(onNext: { [weak self] _ in
            self?.model.registerDevice(phoneNumber: view.phoneNumber)
        }).disposed(by: disposeBag)
    }
}
