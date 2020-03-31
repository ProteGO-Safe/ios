import Foundation
import RxSwift

protocol VerifyCodeViewModelType {

    var stepFinishedObservable: Observable<Void> { get }

    func bind(view: VerifyCodeView)
}
