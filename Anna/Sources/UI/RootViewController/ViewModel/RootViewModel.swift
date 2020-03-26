import Foundation
import CoreLocation

final class RootViewModel: RootViewModelType {

    var locationPermission: CLAuthorizationStatus {
        return model.locationPermission
    }

    private let model: RootModelType

    init(model: RootModelType) {
        self.model = model
    }

    func requestLocationPermissionAlways() {
        model.requestLocationPermissionAlways()
    }

    func startTrackingLocation() {
        model.startTrackingLocation()
    }
}
