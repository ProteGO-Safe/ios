import Foundation
import RealmSwift
import RxSwift

final class RegisteredBeaconIdsDebugScreenModel: RegisteredBeaconIdsDebugScreenModelType {

    var currentBeacon: ExpiringBeaconId? {
        return self.beaconIdsManager.currentExpiringBeaconId
    }

    var allBeaconIds: [RealmExpiringBeacon] {
        return Array(self.beaconIdsManager.allBeaconIds)
    }

    var allBeaconIdsObservable: Observable<RealmExpiringBeacon> {
        return beaconIdsSubject.asObservable()
    }

    private let beaconIdsManager: BeaconIdsManagerType

    private let beaconIdsSubject = PublishSubject<RealmExpiringBeacon>()

    private var notificationToken: NotificationToken?

    init(beaconIdsManager: BeaconIdsManagerType) {
        self.beaconIdsManager = beaconIdsManager

        self.setupBeaconsNotification()
    }

    deinit {
        notificationToken?.invalidate()
    }

    private func setupBeaconsNotification() {
        notificationToken?.invalidate()
        notificationToken = self.beaconIdsManager.allBeaconIds.observe { [weak self] changes in
            guard let self = self else {
                return
            }

            switch changes {
            case .initial: break
            case .update(_, _, let insertions, _):
                for insertionIndex in insertions {
                    self.beaconIdsSubject.onNext(self.beaconIdsManager.allBeaconIds[insertionIndex])
                }

            case .error(let error):
                logger.error("Beacon Ids tracking error: \(error)")
            }
        }
    }
}
