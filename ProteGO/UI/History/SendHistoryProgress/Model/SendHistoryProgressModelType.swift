import Foundation
import RxCocoa
import RxSwift

protocol SendHistoryProgressModelType: class {
    func sendHistory() -> Single<Result<Void, Error>>
}
