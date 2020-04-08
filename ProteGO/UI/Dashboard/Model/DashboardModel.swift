import Foundation
import RxSwift
import RxCocoa

final class DashboardModel: DashboardModelType {
    var currentStatus: BehaviorRelay<DangerStatus> {
        return self.dangerStatusManager.currentStatus
    }

    private let dangerStatusManager: DangerStatusManagerType

    init(dangerStatusManager: DangerStatusManagerType) {
        self.dangerStatusManager = dangerStatusManager
    }
}
