import UIKit
import RxSwift

protocol RegistrationVerifyCodeModelType {

    var stepFinishedObservable: Observable<Void> { get }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> { get }

    func confirmRegistration(code: String)
}
