import Foundation
import RxSwift

protocol RegistrationSendCodeViewModelType {

    var stepFinishedObservable: Observable<SendCodeFinishedData> { get }

    var requestInProgressObservable: Observable<Bool> { get }

    func bind(view: RegistrationSendCodeView)
}
