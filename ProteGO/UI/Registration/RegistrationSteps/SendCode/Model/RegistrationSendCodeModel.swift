import UIKit
import RxSwift
import Valet

struct SendCodeFinishedData {
    let phoneNumber: String
}

final class RegistrationSendCodeModel: RegistrationSendCodeModelType {

    var stepFinishedObservable: Observable<SendCodeFinishedData> {
        return didSendCodeSubject.asObservable()
    }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> {
        keyboardManager.keyboardHeightWillChangeObservable
    }

    private let didSendCodeSubject = PublishSubject<SendCodeFinishedData>()

    private let gcpClient: GcpClientType

    private let valet: Valet

    private let keyboardManager: KeyboardManagerType

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType,
         valet: Valet,
         keyboardManager: KeyboardManagerType) {
        self.gcpClient = gcpClient
        self.valet = valet
        self.keyboardManager = keyboardManager
    }

    func registerDevice(phoneNumber: String) {
        let request = RegisterDeviceRequest(msisdn: phoneNumber)
        return gcpClient.registerDevice(request: request).subscribe(onSuccess: { [weak self] result in
            switch result {
            case .success(let result):
                logger.debug("Did send registration code")
                self?.valet.set(string: result.registrationId, forKey: Constants.KeychainKeys.registrationIdKey)
                self?.didSendCodeSubject.onNext(SendCodeFinishedData(phoneNumber: phoneNumber))
            case .failure(let error):
                logger.error("Failed to send registration code: \(error)")
            }
        }).disposed(by: disposeBag)
    }
}
