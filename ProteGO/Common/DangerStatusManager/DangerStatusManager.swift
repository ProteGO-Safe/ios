import Foundation
import SwiftTweaks
import RxSwift
import RxCocoa

final class DangerStatusManager: DangerStatusManagerType {
    var currentStatus: BehaviorRelay<DangerStatus>

    private var tweakBindings = Set<TweakBindingIdentifier>()

    init() {
        self.currentStatus = BehaviorRelay<DangerStatus>(value: .yellow)

        if DebugMenu.assign(DebugMenu.forceDangerStatus) {
            if let status = DangerStatus.init(rawValue: DebugMenu.assign(DebugMenu.forceDangerStatusValue).value) {
                self.currentStatus.accept(status)
            }

            tweakBindings.insert(DebugMenu.bind(DebugMenu.forceDangerStatusValue) { value in
                if let status = DangerStatus.init(rawValue: value.value) {
                    self.currentStatus.accept(status)
                }
            })
        }
    }

    deinit {
        self.tweakBindings.forEach(DebugMenu.unbind)
    }
}
