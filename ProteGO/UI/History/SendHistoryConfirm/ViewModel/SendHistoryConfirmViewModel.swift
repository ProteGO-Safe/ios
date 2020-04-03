import Foundation
import RxSwift
import RxCocoa

final class SendHistoryConfirmViewModel: SendHistoryConfirmViewModelType {

    private let model: SendHistoryConfirmModelType

    init(model: SendHistoryConfirmModelType) {
        self.model = model
    }

    func bind(view: SendHistoryConfirmView) {
        view.update(phoneId: self.model.phoneId)
    }
}
