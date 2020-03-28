import Foundation
import RealmSwift

final class RegisteredEncountersDebugModel: RegisteredEncountersDebugModelType {

    var allEncounters: [Encounter] {
        return Array(self.encountersManager.allEncounters)
    }

    private let encountersManager: EncountersManagerType

    init(encountersManager: EncountersManagerType) {
        self.encountersManager = encountersManager
    }
}
