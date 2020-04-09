import UIKit
import RxSwift

final class RegistrationSendCodeViewController: UIViewController, CustomView {

    typealias ViewClass = RegistrationSendCodeView

    var stepFinishedObservable: Observable<SendCodeFinishedData> {
        return viewModel.stepFinishedObservable
    }

    var requestInProgressObservable: Observable<Bool> {
        return viewModel.requestInProgressObservable
    }

    private let viewModel: RegistrationSendCodeViewModelType

    init(viewModel: RegistrationSendCodeViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ViewClass()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.bind(view: customView)
    }

    func updateBeforeAppearing() {
        customView.clearTextField()
        customView.update(keyboardHeight: .zero)
    }
}

extension RegistrationSendCodeViewController: DismissKeyboardDelegate {
    func dismissKeyboard() {
        customView.dismissKeyboard()
    }
}
