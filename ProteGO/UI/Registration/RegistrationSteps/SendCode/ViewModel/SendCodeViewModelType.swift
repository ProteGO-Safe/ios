import Foundation
import RxSwift

protocol SendCodeViewModelType {

    var stepFinishedObservable: Observable<Void> { get }

    func bind(view: SendCodeView)
}
