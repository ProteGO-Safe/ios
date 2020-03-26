import Foundation
import CoreLocation
import RxSwift

final class LocationTrackingManager: NSObject, LocationTrackingManagerType {

    var didUpdateLocationsObservable: Observable<[CLLocation]> {
        return didUpdateLocationsSubject.asObservable()
    }

    private let didUpdateLocationsSubject = PublishSubject<[CLLocation]>()

    private let lastLocationRegionRadiusMeters = Double(150)

    private let clLocationManager: CLLocationManager

    private let permissionsManager: PermissionsManagerType

    private let disposeBag = DisposeBag()

    init(clLocationManager: CLLocationManager, permissionsManager: PermissionsManagerType) {
        self.clLocationManager = clLocationManager
        self.permissionsManager = permissionsManager
        super.init()
        setupClLocationManager()
        observeLocationPermissions()
    }

    func startTracking() {
        clLocationManager.startUpdatingLocation()
        clLocationManager.startMonitoringSignificantLocationChanges()
    }

    func stopTracking() {
        clLocationManager.stopUpdatingLocation()
        clLocationManager.stopMonitoringSignificantLocationChanges()
        stopMonitoringRegions()
    }

    func monitorLastLocationRegion() {
        guard let lastLocation = clLocationManager.location else {
            print("Failed to start monitoring last location. Last location is missing.")
            return
        }
        let region = CLCircularRegion(center: lastLocation.coordinate,
                                      radius: lastLocationRegionRadiusMeters,
                                      identifier: "lastLocationRegionId")
        clLocationManager.startMonitoring(for: region)
    }

    private func setupClLocationManager() {
        clLocationManager.pausesLocationUpdatesAutomatically = false
        clLocationManager.allowsBackgroundLocationUpdates = true
        clLocationManager.delegate = self
    }

    private func observeLocationPermissions() {
        permissionsManager.locationPermissionObservable.subscribe(onNext: { [weak self] permission in
            switch permission {
            case .authorizedAlways, .authorizedWhenInUse:
                self?.startTracking()
            default:
                return
            }
        }).disposed(by: disposeBag)
    }

    private func stopMonitoringRegions() {
        for region in clLocationManager.monitoredRegions {
            clLocationManager.stopMonitoring(for: region)
        }
    }
}

extension LocationTrackingManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("clLocationManager didUpdateLocations: \(locations)")
        didUpdateLocationsSubject.onNext(locations)
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("clLocationManager didPauseLocationUpdates")
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("clLocationManager didResumeLocationUpdates")
    }
}
