import Foundation
import RxSwift
import Valet

final class SendCodeModel: SendCodeModelType {

    var stepFinishedObservable: Observable<Void> {
        return didSendCodeSubject.asObservable()
    }

    private let didSendCodeSubject = PublishSubject<Void>()

    private let gcpClient: GcpClientType

    private let valet: Valet

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType,
         valet: Valet) {
        self.gcpClient = gcpClient
        self.valet = valet
    }

    func registerDevice(phoneNumber: String) {
        let request = RegisterDeviceRequest(msisdn: phoneNumber)
        return gcpClient.registerDevice(request: request).subscribe(onSuccess: { [weak self] result in
            switch result {
            case .success(let result):
                logger.debug("Did send registration code")
                self?.valet.set(string: result.registrationId, forKey: Constants.KeychainKeys.registrationIdKey)
                self?.didSendCodeSubject.onNext(())
            case .failure(let error):
                logger.error("Failed to send registration code: \(error)")
            }
        }).disposed(by: disposeBag)
    }
}
