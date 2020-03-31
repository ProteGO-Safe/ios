import UIKit
import RxSwift

final class VerifyCodeViewController: UIViewController, CustomView {

    typealias ViewClass = VerifyCodeView

    var stepFinishedObservable: Observable<Void> {
        return viewModel.stepFinishedObservable
    }

    private let viewModel: VerifyCodeViewModelType

    init(viewModel: VerifyCodeViewModelType) {
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

    func update(phoneNumber: String) {
        customView.update(phoneNumber: phoneNumber)
    }
}

extension VerifyCodeViewController: DismissKeyboardDelegate {

    func dismissKeyboard() {
        customView.dismissKeyboard()
    }
}

extension VerifyCodeViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.confirmRegistration(code: customView.code)
        return true
    }
}
