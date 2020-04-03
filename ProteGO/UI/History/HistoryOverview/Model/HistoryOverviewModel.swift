import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import Valet

final class HistoryOverviewModel: HistoryOverviewModelType {
    var phoneId: String {
        guard let text = self.valet.string(forKey: Constants.KeychainKeys.userIdKey) else {
            return L10n.dashboardInfoIdPlacehloder
        }
        return String(text.prefix(Int(floor(Double(text.count) * 0.25))))
    }

    var historyLastDate: BehaviorRelay<Date>

    var lastSeenDevicesCount: BehaviorRelay<Int>

    private let encountersManager: EncountersManagerType

    private let valet: Valet

    private var lastHistoryDateUpdatingTimer: Timer?

    private var notificationToken: NotificationToken?

    init(encountersManager: EncountersManagerType, valet: Valet) {
        self.encountersManager = encountersManager
        self.valet = valet

        self.historyLastDate = BehaviorRelay<Date>(value: Date())
        self.lastSeenDevicesCount = BehaviorRelay<Int>(value: 0)
        self.setupLastHistoryDateUpdating()
        self.updateLastHistoryDate()
        self.setupEncountersCounterNotification()
    }

    deinit {
        self.lastHistoryDateUpdatingTimer?.invalidate()
        notificationToken?.invalidate()
    }

    private func setupLastHistoryDateUpdating() {
        let timer = Timer.init(
            timeInterval: Constants.HistoryOverview.lastHistoryDateUpdateInterval,
            repeats: true) { [weak self] _ in
                self?.updateLastHistoryDate()
                self?.setupEncountersCounterNotification()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.lastHistoryDateUpdatingTimer = timer
    }

    private func updateLastHistoryDate() {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        dateComponents.minute = 0
        if let newDate = Calendar.current.date(from: dateComponents) {
            self.historyLastDate.accept(newDate)
            self.setupEncountersCounterNotification()
        }
    }

    private func setupEncountersCounterNotification() {
        notificationToken?.invalidate()
        let date = self.historyLastDate.value
        notificationToken = self.encountersManager.uniqueEncountersSince(date: date).observe { [weak self] changes in
            guard let self = self else {
                return
            }

            switch changes {
            case .initial, .update:
                let count = self.encountersManager.uniqueEncountersSince(date: self.historyLastDate.value).count
                self.lastSeenDevicesCount.accept(count)
            case .error(let error):
                logger.error("Encounters count tracking error: \(error)")
            }
        }
    }
}
