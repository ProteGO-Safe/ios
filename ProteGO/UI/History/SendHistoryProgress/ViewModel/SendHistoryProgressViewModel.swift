import Foundation
import RxSwift
import RxCocoa

final class SendHistoryProgressViewModel: SendHistoryProgressViewModelType {

    func sendHistory() -> Single<Result<Void, Error>> {
        return self.model.sendHistory()
    }

    private let model: SendHistoryProgressModelType

    private let disposeBag = DisposeBag()

    init(model: SendHistoryProgressModelType) {
        self.model = model
    }

    func bind(view: SendHistoryProgressView) {
    }
}
