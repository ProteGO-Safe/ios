import Foundation
import RxSwift

protocol SendHistoryProgressViewModelType: class {
    func sendHistory(confirmCode: String) -> Single<Result<Void, Error>>

    func bind(view: SendHistoryProgressView)
}
