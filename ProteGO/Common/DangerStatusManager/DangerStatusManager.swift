import Foundation
import SwiftTweaks
import RxSwift
import RxCocoa
import Valet

final class DangerStatusManager: DangerStatusManagerType {

    var currentStatus: BehaviorRelay<DangerStatus>

    private var tweakBindings = Set<TweakBindingIdentifier>()

    private let gcpClient: GcpClientType

    private let valet: Valet

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType, valet: Valet) {
        self.gcpClient = gcpClient
        self.valet = valet

        var initialDangerStatus = DangerStatus.yellow
        if let rawDangerStatusValue = valet.string(forKey: Constants.KeychainKeys.currentDangerStatus),
            let dangerStatus = DangerStatus(rawValue: rawDangerStatusValue) {
            initialDangerStatus = dangerStatus
        }
        self.currentStatus = BehaviorRelay<DangerStatus>(value: initialDangerStatus)

        self.setupForcedStatusHandling()
    }

    deinit {
        self.tweakBindings.forEach(DebugMenu.unbind)
    }

    func setupForcedStatusHandling() {
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

    func updateCurrentDangerStatus() {
        guard !DebugMenu.assign(DebugMenu.forceDangerStatus) else {
            return
        }

        return self.gcpClient.getStatus().subscribe(onSuccess: { [weak self] result in
            guard let self = self else {
                logger.error("Instance deallocated file: \(#file), line: \(#line)")
                return
            }

            switch result {
            case .success(let result):
                self.currentStatus.accept(result.status)
                self.valet.set(string: result.status.rawValue, forKey: Constants.KeychainKeys.currentDangerStatus)
            case .failure(let error):
                logger.error("Error occurred during status update: \(error)")
                return
            }
        }).disposed(by: disposeBag)
    }
}
