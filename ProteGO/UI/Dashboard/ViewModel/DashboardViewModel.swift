import Foundation
import RxSwift

final class DashboardViewModel: DashboardViewModelType {

    private let disposeBag: DisposeBag = DisposeBag()

    private let model: DashboardModelType

    init(model: DashboardModelType) {
        self.model = model
    }

    func bind(view: DashboardView) {
        self.model.currentStatus
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { status in
            view.update(withStatus: status)
        }).disposed(by: self.disposeBag)
    }
}
