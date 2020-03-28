import Foundation
import RealmSwift

final class RegisteredEncountersDebugViewModel: RegisteredEncountersDebugViewModelType {

    private let model: RegisteredEncountersDebugModelType

    init(model: RegisteredEncountersDebugModelType) {
        self.model = model
    }

    func bind(view: RegisteredEncountersDebugScreenView) {
        for encounter in self.model.allEncounters {
            view.addEncounterData(deviceId: encounter.deviceId,
                                  signalStrength: encounter.signalStrength,
                                  date: encounter.date)
        }
    }
}
