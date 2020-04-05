import Foundation
import RxSwift

protocol SendHistoryProgressViewModelType: class {
    var didFinishHistorySendingObservable: Observable<Result<Void, Error>> { get }

    func bind(view: SendHistoryProgressView)
}
