import Foundation
import RxSwift

protocol RegistrationVerifyCodeViewModelType {

    var stepFinishedObservable: Observable<Void> { get }

    var requestInProgressObservable: Observable<Bool> { get }

    func bind(view: RegistrationVerifyCodeView)

    func confirmRegistration(code: String)
}
