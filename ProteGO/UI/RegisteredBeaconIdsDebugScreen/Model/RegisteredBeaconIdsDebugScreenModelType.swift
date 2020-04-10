import Foundation
import RxSwift
import RealmSwift

protocol RegisteredBeaconIdsDebugScreenModelType {

    var currentBeacon: ExpiringBeaconId? { get }

    var allBeaconIds: [RealmExpiringBeacon] { get }

    var allBeaconIdsObservable: Observable<RealmExpiringBeacon> { get }
}
