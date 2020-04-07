import Foundation
import SwiftTweaks
import RxSwift
import RxCocoa
import Valet

final class DangerStatusManager: DangerStatusManagerType {

    var currentStatus: BehaviorRelay<DangerStatus>

    private var tweakBindings = Set<TweakBindingIdentifier>()

    private let gcpClient: GcpClientType

    private let keychainProvider: KeychainProviderType

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType, keychainProvider: KeychainProviderType) {
        self.gcpClient = gcpClient
        self.keychainProvider = keychainProvider

        let initialDangerStatus = keychainProvider.string(forKey: Constants.KeychainKeys.currentDangerStatus)
            .flatMap(DangerStatus.init(rawValue:)) ?? .yellow

        self.currentStatus = BehaviorRelay<DangerStatus>(value: initialDangerStatus)
    }

    func updateCurrentDangerStatus() {
        return self.gcpClient.getStatus().subscribe(onSuccess: { [weak self] result in
            guard let self = self else {
                logger.error("Instance deallocated file: \(#file), line: \(#line)")
                return
            }

            switch result {
            case .success(let result):
                self.currentStatus.accept(result.status)
                self.keychainProvider.set(string: result.status.rawValue, forKey: Constants.KeychainKeys.currentDangerStatus)
            case .failure(let error):
                logger.error("Error occurred during status update: \(error)")
                return
            }
        }).disposed(by: disposeBag)
    }
}
