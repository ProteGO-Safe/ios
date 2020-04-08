import Foundation
import RxSwift
import RxCocoa

final class StatusManager: StatusManagerType {

    private let gcpClient: GcpClientType

    private let registrationManager: RegistrationManagerType

    private let beaconIdsManager: BeaconIdsManagerType

    private let dangerStatusManager: DangerStatusManagerType

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType,
         registrationManager: RegistrationManagerType,
         beaconIdsManager: BeaconIdsManagerType,
         dangerStatusManager: DangerStatusManagerType) {
        self.gcpClient = gcpClient
        self.registrationManager = registrationManager
        self.beaconIdsManager = beaconIdsManager
        self.dangerStatusManager = dangerStatusManager
        self.setupRegistrationObserving()
    }

    func updateCurrentDangerStatusAndBeaconIds() {
        self.gcpClient.getStatus(lastBeaconDate: self.beaconIdsManager.lastStoredExpiringBeaconDate)
            .subscribe(onSuccess: { [weak self] result in
            guard let self = self else {
                logger.error("Instance deallocated file: \(#file), line: \(#line)")
                return
            }

            switch result {
            case .success(let result):
                self.dangerStatusManager.update(with: result.status)
                self.beaconIdsManager.update(with: result.beaconIds)
            case .failure(let error):
                logger.error("Error occurred during status update: \(error)")
                return
            }
        }).disposed(by: disposeBag)
    }

    private func setupRegistrationObserving() {
        self.registrationManager.isUserRegisteredObservable.subscribe(onNext: { [weak self] _ in
            guard let self = self else {
                logger.error("Instance deallocated file: \(#file), line: \(#line)")
                return
            }

            self.updateCurrentDangerStatusAndBeaconIds()
        }).disposed(by: disposeBag)
    }
}
