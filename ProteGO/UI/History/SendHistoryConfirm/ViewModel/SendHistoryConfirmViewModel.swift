import Foundation
import RxSwift
import RxCocoa

final class SendHistoryConfirmViewModel: SendHistoryConfirmViewModelType {

    private let model: SendHistoryConfirmModelType

    private let disposeBag = DisposeBag()

    init(model: SendHistoryConfirmModelType) {
        self.model = model
    }

    func bind(view: SendHistoryConfirmView) {
        view.update(phoneId: self.model.phoneId)

        model.keyboardHeightWillChangeObservable.subscribe(onNext: { keyboardHeight in
            view.update(keyboardHeight: keyboardHeight)
        }) .disposed(by: disposeBag)
    }
}
