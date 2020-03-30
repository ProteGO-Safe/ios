import Foundation
import RxSwift

final class VerifyCodeViewModel: VerifyCodeViewModelType {

    var stepFinishedObservable: Observable<Void> {
        return model.stepFinishedObservable
    }

    private let model: VerifyCodeModelType

    private let disposeBag = DisposeBag()

    init(model: VerifyCodeModelType) {
        self.model = model
    }

    func bind(view: VerifyCodeView) {
        view.verifyCodeButtonTapEvent.subscribe(onNext: { [weak self] _ in
            self?.model.confirmRegistration(code: view.code)
        }).disposed(by: disposeBag)
    }
}
