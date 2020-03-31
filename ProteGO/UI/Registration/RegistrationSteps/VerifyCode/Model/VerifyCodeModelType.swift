import Foundation
import RxSwift

protocol VerifyCodeModelType {

    var stepFinishedObservable: Observable<Void> { get }

    func confirmRegistration(code: String)
}
