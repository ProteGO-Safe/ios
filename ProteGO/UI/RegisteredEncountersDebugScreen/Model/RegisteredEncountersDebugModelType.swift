import Foundation
import RxSwift

protocol RegisteredEncountersDebugModelType {
    var allEncounters: [Encounter] { get }

    var allEncountersObservable: Observable<Encounter> { get }
}
