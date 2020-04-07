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
        if let beacon = model.currentBeacon, let beaconId = beacon.getBeaconId() {
            view.addBeaconData(beaconData: beaconId.getData(),
                               date: beacon.expirationDate,
                               prefix: "Current")
        }

        for beacon in self.model.allBeaconIds {
            view.addBeaconData(beaconData: beacon.beaconIdData, date: beacon.expirationDate)
        }

        model.allBeaconIdsObservable
            .subscribe(onNext: {  beacon in
                view.addBeaconData(beaconData: beacon.beaconIdData, date: beacon.expirationDate)
            }).disposed(by: disposeBag)
    }
}
