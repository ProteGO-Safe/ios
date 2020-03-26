import Foundation
import CoreLocation
import RxSwift

final class PermissionsManager: NSObject, PermissionsManagerType {

    var locationPermission: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    var locationPermissionObservable: Observable<CLAuthorizationStatus> {
        return locationPermissionSubject.asObservable()
    }

    private lazy var locationPermissionSubject = BehaviorSubject<CLAuthorizationStatus>(value: locationPermission)

    private let clLocationManager: CLLocationManager

    init(clLocationManager: CLLocationManager) {
        self.clLocationManager = clLocationManager
        super.init()
        self.clLocationManager.delegate = self
    }

    func requestLocationPermissionAlways() {
        clLocationManager.requestAlwaysAuthorization()
    }
}

extension PermissionsManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("locationManager didChangeAuthorization status: \(status)")
        locationPermissionSubject.onNext(status)
    }
}
