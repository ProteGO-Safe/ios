import Foundation
import RxSwift

protocol RegistrationSendCodeViewModelType {

    var stepFinishedObservable: Observable<SendCodeFinishedData> { get }

    func bind(view: RegistrationSendCodeView)
}
