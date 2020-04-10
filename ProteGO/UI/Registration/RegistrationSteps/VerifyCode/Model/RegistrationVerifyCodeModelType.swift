import UIKit
import RxSwift

protocol RegistrationVerifyCodeModelType {

    var stepFinishedObservable: Observable<Void> { get }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> { get }

    var requestInProgressObservable: Observable<Bool> { get }

    func confirmRegistration(code: String)
}
