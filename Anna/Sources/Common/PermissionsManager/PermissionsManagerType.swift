import Foundation
import CoreLocation
import RxSwift

protocol PermissionsManagerType {

    var locationPermission: CLAuthorizationStatus { get }

    var locationPermissionObservable: Observable<CLAuthorizationStatus> { get }

    func requestLocationPermissionAlways()
}
