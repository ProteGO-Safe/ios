import Foundation
import RealmSwift
import RxSwift

final class RegisteredBeaconIdsDebugScreenViewModel: RegisteredBeaconIdsDebugScreenViewModelType {

    private let model: RegisteredBeaconIdsDebugScreenModelType

    private let disposeBag: DisposeBag = DisposeBag()

    init(model: RegisteredBeaconIdsDebugScreenModelType) {
        self.model = model
    }

    func bind(view: RegisteredBeaconIdsDebugScreenView) {
        if let beacon = model.currentBeacon?.getBeaconId() {
            view.addCurrentBeaconData(beaconData: beacon.getData())
        }

        for beacon in self.model.allBeaconIds {
            view.addBeaconData(beaconData: beacon.beaconIdData, date: beacon.startDate)
        }

        model.allBeaconIdsObservable
            .subscribe(onNext: {  beacon in
                view.addBeaconData(beaconData: beacon.beaconIdData, date: beacon.startDate)
            }).disposed(by: disposeBag)
    }
}
