import Foundation
import RxCocoa

final class DangerStatusManager: DangerStatusManagerType {

    var currentStatus: BehaviorRelay<DangerStatus>

    private let keychainProvider: KeychainProviderType

    init(keychainProvider: KeychainProviderType) {
        self.keychainProvider = keychainProvider

        let initialDangerStatus = keychainProvider.string(forKey: Constants.KeychainKeys.currentDangerStatus)
            .flatMap(DangerStatus.init(rawValue:)) ?? .yellow

        self.currentStatus = BehaviorRelay<DangerStatus>(value: initialDangerStatus)
    }

    func update(with status: DangerStatus) {
        self.currentStatus.accept(status)
        self.keychainProvider.set(string: status.rawValue, forKey: Constants.KeychainKeys.currentDangerStatus)
    }
}
