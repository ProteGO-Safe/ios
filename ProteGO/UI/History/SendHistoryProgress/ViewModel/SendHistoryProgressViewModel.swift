import Foundation
import RxSwift
import RxCocoa

final class SendHistoryProgressViewModel: SendHistoryProgressViewModelType {

    var didFinishHistorySendingObservable: Observable<Result<Void, Error>> {
        return self.model.didFinishHistorySendingObservable
    }

    private let model: SendHistoryProgressModelType

    private let disposeBag = DisposeBag()

    init(model: SendHistoryProgressModelType) {
        self.model = model
    }

    func bind(view: SendHistoryProgressView) {
    }
}
