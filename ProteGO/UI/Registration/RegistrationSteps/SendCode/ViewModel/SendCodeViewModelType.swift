import Foundation
import RxSwift

protocol SendCodeViewModelType {

    var stepFinishedObservable: Observable<SendCodeFinishedData> { get }

    func bind(view: SendCodeView)
}
