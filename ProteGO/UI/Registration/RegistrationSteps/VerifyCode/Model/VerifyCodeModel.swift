import Foundation
import RxSwift
import Valet

final class VerifyCodeModel: VerifyCodeModelType {

    var stepFinishedObservable: Observable<Void> {
        return didVerifyCode.asObservable()
    }

    private let didVerifyCode = PublishSubject<Void>()

    private let gcpClient: GcpClientType

    private let valet: Valet

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType,
         valet: Valet) {
        self.gcpClient = gcpClient
        self.valet = valet
    }

    func confirmRegistration(code: String) {
        guard let registrationId = valet.string(forKey: Constants.KeychainKeys.registrationIdKey) else {
            logger.error("Failed to retrieve registrationId")
            return
        }
        let request = ConfirmRegistrationRequest(code: code, registrationId: registrationId)

        return gcpClient.confirmRegistration(request: request).subscribe(onSuccess: { [weak self] result in
            switch result {
            case .success(let result):
                logger.debug("Did verify registration code")
                self?.valet.set(string: result.userId, forKey: Constants.KeychainKeys.userIdKey)
                self?.didVerifyCode.onNext(())
            case .failure(let error):
                logger.error("Failed to verify registration code: \(error)")
            }
        }).disposed(by: disposeBag)
    }
}
