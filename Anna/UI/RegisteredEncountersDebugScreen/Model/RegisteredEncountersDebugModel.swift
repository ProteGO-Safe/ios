import Foundation
import RealmSwift
import RxSwift

final class RegisteredEncountersDebugModel: RegisteredEncountersDebugModelType {

    var allEncounters: [Encounter] {
        return Array(self.encountersManager.allEncounters)
    }

    var allEncountersObservable: Observable<Encounter> {
        return encountersSubject.asObservable()
    }

    private let encountersManager: EncountersManagerType

    private let encountersSubject = PublishSubject<Encounter>()

    private var notificationToken: NotificationToken?

    init(encountersManager: EncountersManagerType) {
        self.encountersManager = encountersManager

        self.setupEncountersNotification()
    }

    deinit {
        notificationToken?.invalidate()
    }

    private func setupEncountersNotification() {
        notificationToken?.invalidate()
        notificationToken = self.encountersManager.allEncounters.observe { [weak self] changes in
            guard let self = self else {
                return
            }

            switch changes {
            case .initial: break
            case .update(_, _, let insertions, _):
                for insertionIndex in insertions {
                    self.encountersSubject.onNext(self.encountersManager.allEncounters[insertionIndex])
                }

            case .error(let error):
                logger.error("Encounters tracking error: \(error)")
            }
        }
    }
}
