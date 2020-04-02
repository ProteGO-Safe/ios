import Foundation
import RxSwift
import RxCocoa

final class HistoryOverviewModel: HistoryOverviewModelType {
    var phoneId: BehaviorRelay<String>

    var historyLastDate: BehaviorRelay<String>

    var lastSeenDevicesCount: BehaviorRelay<String>

    private let encountersManasger: EncountersManagerType

    init(encountersManasger: EncountersManagerType) {
        self.encountersManasger = encountersManasger

        //TODO
        self.phoneId = BehaviorRelay<String>(value: L10n.dashboardInfoIdPlacehloder)
        self.historyLastDate = BehaviorRelay<String>(value: "13:00")
        self.lastSeenDevicesCount = BehaviorRelay<String>(value: "5")
    }
}
