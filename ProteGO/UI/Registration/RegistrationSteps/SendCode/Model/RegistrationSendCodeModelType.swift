import UIKit
import RxSwift

protocol RegistrationSendCodeModelType {

    var stepFinishedObservable: Observable<SendCodeFinishedData> { get }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> { get }

    func registerDevice(phoneNumber: String)

    func registerWithoutPhoneNumber()
}
