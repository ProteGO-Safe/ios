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
        view = ViewClass()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.bind(view: customView)
    }
}
