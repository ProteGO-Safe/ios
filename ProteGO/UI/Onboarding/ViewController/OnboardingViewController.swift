import UIKit

final class OnboardingViewController: UIViewController, CustomView {

    typealias ViewClass = OnboardingView

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
