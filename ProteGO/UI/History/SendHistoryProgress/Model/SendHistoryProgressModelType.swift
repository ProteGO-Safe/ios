import Foundation
import RxCocoa
import RxSwift

protocol SendHistoryProgressModelType: class {
    func sendHistory(confirmCode: String) -> Single<Result<Void, Error>>
}
