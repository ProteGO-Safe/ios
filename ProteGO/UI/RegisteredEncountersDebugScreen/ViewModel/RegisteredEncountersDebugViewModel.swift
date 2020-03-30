import Foundation
import RealmSwift
import RxSwift

final class RegisteredEncountersDebugViewModel: RegisteredEncountersDebugViewModelType {

    private let model: RegisteredEncountersDebugModelType

    private let disposeBag: DisposeBag = DisposeBag()

    init(model: RegisteredEncountersDebugModelType) {
        self.model = model
    }

    func bind(view: RegisteredEncountersDebugScreenView) {
        for encounter in self.model.allEncounters {
            view.addEncounterData(deviceId: encounter.deviceId,
                                  signalStrength: encounter.signalStrength.value,
                                  date: encounter.date)
        }

        model.allEncountersObservable
            .subscribe(onNext: {  encounter in
                view.addEncounterData(deviceId: encounter.deviceId,
                                      signalStrength: encounter.signalStrength.value,
                                      date: encounter.date)
            }).disposed(by: disposeBag)
    }
}
