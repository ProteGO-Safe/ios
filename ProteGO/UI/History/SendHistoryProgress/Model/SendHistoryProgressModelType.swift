import Foundation
import RxCocoa
import RxSwift

protocol SendHistoryProgressModelType: class {
    var didFinishHistorySendingObservable: Observable<Result<Void, Error>> { get }
}
