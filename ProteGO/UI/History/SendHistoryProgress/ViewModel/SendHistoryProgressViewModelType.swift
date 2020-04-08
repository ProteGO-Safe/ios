import Foundation
import RxSwift

protocol SendHistoryProgressViewModelType: class {
    func sendHistory() -> Single<Result<Void, Error>>

    func bind(view: SendHistoryProgressView)
}
