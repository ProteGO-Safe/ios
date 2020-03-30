import UIKit

final class DashboardViewController: UIViewController, CustomView {

    typealias ViewClass = DashboardView

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
