import UIKit
import RxSwift

enum SendCodeFinishedData {
    case sendCode(phoneNumber: String)
    case registerWithoutPhoneNumber
}

final class RegistrationSendCodeModel: RegistrationSendCodeModelType {

    var stepFinishedObservable: Observable<SendCodeFinishedData> {
        return stepFinishedSubject.asObservable()
    }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> {
        keyboardManager.keyboardHeightWillChangeObservable
    }

    var requestInProgressObservable: Observable<Bool> {
        return requestInProgressSubject.asObservable()
    }

    private let stepFinishedSubject = PublishSubject<SendCodeFinishedData>()

    private let requestInProgressSubject = BehaviorSubject<Bool>(value: false)

    private let gcpClient: GcpClientType

    private let keyboardManager: KeyboardManagerType

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType,
         keyboardManager: KeyboardManagerType) {
        self.gcpClient = gcpClient
        self.keyboardManager = keyboardManager
    }

    func registerDevice(phoneNumber: String) {
        requestInProgressSubject.onNext(true)
        return gcpClient.registerDevice(msisdn: phoneNumber).subscribe(onSuccess: { [weak self] result in
            self?.requestInProgressSubject.onNext(false)
            switch result {
            case .success:
                self?.stepFinishedSubject.onNext(.sendCode(phoneNumber: phoneNumber))
            case .failure:
                return
            }
        }).disposed(by: disposeBag)
    }

    func registerWithoutPhoneNumber() {
        requestInProgressSubject.onNext(true)
        return gcpClient.registerNoMsisdn().subscribe(onSuccess: { [weak self] result in
            self?.requestInProgressSubject.onNext(false)
            switch result {
            case .success:
                self?.stepFinishedSubject.onNext((.registerWithoutPhoneNumber))
            case .failure:
                return
            }
        }).disposed(by: disposeBag)
    }
}
