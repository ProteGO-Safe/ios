import UIKit
import RxSwift

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

    private let keyboardManager: KeyboardManagerType

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType,
         keyboardManager: KeyboardManagerType) {
        self.gcpClient = gcpClient
        self.keyboardManager = keyboardManager
    }

    func registerDevice(phoneNumber: String) {
        return gcpClient.registerDevice(msisdn: phoneNumber).subscribe(onSuccess: { [weak self] result in
            switch result {
            case .success:
                self?.didSendCodeSubject.onNext(SendCodeFinishedData(phoneNumber: phoneNumber))
            case .failure:
                return
            }
        }).disposed(by: disposeBag)
    }
}
