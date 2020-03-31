import Foundation
import RxSwift

protocol SendCodeModelType {

    var stepFinishedObservable: Observable<SendCodeFinishedData> { get }

    func registerDevice(phoneNumber: String)
}
