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
        view.update(phoneId: self.model.phoneId)

        BehaviorRelay.combineLatest(self.model.historyLastDate, self.model.lastSeenDevicesCount)
            .subscribe(onNext: { historyLastDate, lastSeenDevicesCount in
                let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: historyLastDate)
                if let hour = dateComponents.hour, let minute = dateComponents.minute {
                    let dateString = "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
                    view.update(historyLastDate: dateString, lastSeenDevicesCount: "\(lastSeenDevicesCount)")
                }
            }).disposed(by: self.disposeBag)
    }
}
