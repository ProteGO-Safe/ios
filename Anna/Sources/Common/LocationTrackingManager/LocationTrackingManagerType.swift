import Foundation
import CoreLocation
import RxSwift

protocol LocationTrackingManagerType {

    var didUpdateLocationsObservable: Observable<[CLLocation]> { get }

    func startTracking()

    func stopTracking()

    func monitorLastLocationRegion()
}

