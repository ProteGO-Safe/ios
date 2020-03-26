import Foundation
import CoreLocation

protocol RootModelType {

    var locationPermission: CLAuthorizationStatus { get }

    func requestLocationPermissionAlways()

    func startTrackingLocation()
}
