import Foundation
import RxSwift

protocol ReegistrationVerifyCodeViewModelType {

    var stepFinishedObservable: Observable<Void> { get }

    func bind(view: RegistrationVerifyCodeView)

    func confirmRegistration(code: String)
}
