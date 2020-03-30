import Foundation
import RxSwift

protocol SendCodeModelType {

    var stepFinishedObservable: Observable<Void> { get }

    func registerDevice(phoneNumber: String)
}
