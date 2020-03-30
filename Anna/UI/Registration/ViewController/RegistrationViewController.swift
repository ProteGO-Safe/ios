import UIKit

protocol RegistrationViewControllerDelegate: class {
    func didTapBackButton()
}

final class RegistrationViewController: UIViewController, CustomView {

    typealias ViewClass = RegistrationView

    weak var delegate: RegistrationViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ViewClass()
    }
}
