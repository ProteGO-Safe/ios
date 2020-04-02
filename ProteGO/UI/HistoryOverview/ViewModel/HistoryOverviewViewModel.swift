import Foundation
import RxSwift
import RxCocoa

final class HistoryOverviewViewModel: HistoryOverviewViewModelType {

    private let model: HistoryOverviewModelType

    private let disposeBag: DisposeBag = DisposeBag()

    init(model: HistoryOverviewModelType) {
        self.model = model
    }

    func bind(view: HistoryOverviewView) {
        self.model.phoneId.subscribe(onNext: { phoneId in
            view.update(phoneId: phoneId)
        }).disposed(by: self.disposeBag)

        BehaviorRelay.combineLatest(self.model.historyLastDate, self.model.lastSeenDevicesCount)
            .subscribe(onNext: { historyLastDate, lastSeenDevicesCount in
                view.update(historyLastDate: historyLastDate, lastSeenDevicesCount: lastSeenDevicesCount)
            }).disposed(by: self.disposeBag)

        self.model.phoneId.subscribe(onNext: { phoneId in
            view.update(phoneId: phoneId)
        }).disposed(by: self.disposeBag)
    }
}
