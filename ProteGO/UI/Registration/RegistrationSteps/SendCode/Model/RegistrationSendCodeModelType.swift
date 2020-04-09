import UIKit
import RxSwift

protocol RegistrationSendCodeModelType: AnyObject {

    var stepFinishedObservable: Observable<SendCodeFinishedData> { get }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> { get }

    func registerDevice(phoneNumber: String)
}
