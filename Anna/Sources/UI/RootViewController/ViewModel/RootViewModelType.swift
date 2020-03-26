import Foundation
import CoreLocation

protocol RootViewModelType {

    var locationPermission: CLAuthorizationStatus { get }

    func requestLocationPermissionAlways()

    func startTrackingLocation()
}
