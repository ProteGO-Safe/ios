import Swinject
import CoreLocation

final class LocationTrackingAssembly: Assembly {

    func assemble(container: Container) {
        registerLocationTrackingManager(container)
        registerPermissionsManager(container)
    }

    private func registerLocationTrackingManager(_ container: Container) {
        container.register(LocationTrackingManagerType.self) { resolver in
            let clLocationManager = CLLocationManager()
            return LocationTrackingManager(
                clLocationManager: clLocationManager,
                permissionsManager: resolver.resolve(PermissionsManagerType.self)
            )
        }
    }

    private func registerPermissionsManager(_ container: Container) {
        container.register(PermissionsManagerType.self) { _ in
            let clLocationManager = CLLocationManager()
            return PermissionsManager(clLocationManager: clLocationManager)
        }
    }
}
