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
        return gcpClient.confirmRegistration(code: code).subscribe(onSuccess: { [weak self] result in
            switch result {
            case .success:
                self?.didVerifyCode.onNext(())
            case .failure:
                return
            }
        }).disposed(by: disposeBag)
    }
}
