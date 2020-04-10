import UIKit
import RxSwift
import Valet

final class RegistrationVerifyCodeModel: RegistrationVerifyCodeModelType {

    var stepFinishedObservable: Observable<Void> {
        return didVerifyCode.asObservable()
    }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> {
        keyboardManager.keyboardHeightWillChangeObservable
    }

    var requestInProgressObservable: Observable<Bool> {
        return requestInProgressSubject.asObservable()
    }

    private let requestInProgressSubject = BehaviorSubject<Bool>(value: false)

    private let didVerifyCode = PublishSubject<Void>()

    private let gcpClient: GcpClientType

    private let keyboardManager: KeyboardManagerType

    private let disposeBag = DisposeBag()

    init(gcpClient: GcpClientType,
         keyboardManager: KeyboardManagerType) {
        self.gcpClient = gcpClient
        self.keyboardManager = keyboardManager
    }

    func confirmRegistration(code: String) {
        requestInProgressSubject.onNext(true)
        return gcpClient.confirmRegistration(code: code).subscribe(onSuccess: { [weak self] result in
            self?.requestInProgressSubject.onNext(false)
            switch result {
            case .success:
                self?.didVerifyCode.onNext(())
            case .failure:
                return
            }
        }).disposed(by: disposeBag)
    }
}
