import Foundation
import Mimus
import RxSwift
import RxCocoa
@testable import ProteGO

final class DangerStatusManagerMock: DangerStatusManagerType, Mock {
    var currentStatus = BehaviorRelay<DangerStatus>.init(value: .yellow)

    var storage: [RecordedCall] = []

    func update(with status: DangerStatus) {
        recordCall(withIdentifier: "update", arguments: [status])
    }
}
