import Foundation
import CoreLocation

final class RootModel: RootModelType {

    var locationPermission: CLAuthorizationStatus {
        return permissionsManager.locationPermission
    }

    private let locationTrackingManager: LocationTrackingManagerType

    private let permissionsManager: PermissionsManagerType

    init(locationTrackingManager: LocationTrackingManagerType,
         permissionsManager: PermissionsManagerType) {
        self.locationTrackingManager = locationTrackingManager
        self.permissionsManager = permissionsManager
    }

    func requestLocationPermissionAlways() {
        permissionsManager.requestLocationPermissionAlways()
    }

    func startTrackingLocation() {
        locationTrackingManager.startTracking()
    }
}
