import Foundation
import RxSwift

protocol RegistrationViewModelType {

    var currentStepObservable: Observable<RegistrationStep> { get }

    var goBackObservable: Observable<Void> { get }

    var registrationFinishedObservable: Observable<Void> { get }

    var dismissKeyboardObservable: Observable<Void> { get }

    func bind(view: RegistrationView)

    func bind(sendCodeViewController: RegistrationSendCodeViewController)

    func bind(verifyCodeViewController: RegistrationVerifyCodeViewController)

    func setInitialStep()
}
