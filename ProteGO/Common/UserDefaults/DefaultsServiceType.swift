import Foundation
import RxSwift

protocol DefaultsServiceType: class {

    var finishedFirstAppLaunch: Bool { get set }

    var finishedOnboarding: Bool { get set }

    func valueChangeObservable<T>(key: DefaultsKey) -> Observable<T>
}
