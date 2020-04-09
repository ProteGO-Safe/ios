import UIKit
import RxSwift

final class RegistrationVerifyCodeViewController: UIViewController, CustomView {

    typealias ViewClass = RegistrationVerifyCodeView

    var stepFinishedObservable: Observable<Void> {
        return viewModel.stepFinishedObservable
    }

    var requestInProgressObservable: Observable<Bool> {
        return viewModel.requestInProgressObservable
    }

    private let viewModel: RegistrationVerifyCodeViewModelType

    init(viewModel: RegistrationVerifyCodeViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ViewClass(codeTextFieldDelegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.bind(view: customView)
    }

    func updateBeforeAppearing(phoneNumber: String) {
        customView.update(phoneNumber: phoneNumber)
        customView.clearTextField()
        customView.update(keyboardHeight: .zero)
    }
}

extension RegistrationVerifyCodeViewController: DismissKeyboardDelegate {

    func dismissKeyboard() {
        customView.dismissKeyboard()
    }
}

extension RegistrationVerifyCodeViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.confirmRegistration(code: customView.code)
        return true
    }
}
