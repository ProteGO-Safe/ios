import UIKit
import RxSwift

typealias SendHistoryProgressViewControllerBuilder = (/* code */String) -> SendHistoryProgressViewController

protocol SendHistoryProgressViewControllerDelegate: class {
    func sendHistoryFinished(result: Result<Void, Error>)
}

final class SendHistoryProgressViewController: UIViewController, CustomView {

    typealias ViewClass = SendHistoryProgressView

    weak var delegate: SendHistoryProgressViewControllerDelegate?

    private let viewModel: SendHistoryProgressViewModelType

    private let confirmCode: String

    private let disposeBag: DisposeBag = DisposeBag()

    init(confirmCode: String, viewModel: SendHistoryProgressViewModelType) {
        self.confirmCode = confirmCode
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
        self.viewModel.bind(view: customView)
        self.bindViewModelEvents()
        customView.startAnimation()
    }

    private func bindViewModelEvents() {
        self.viewModel.sendHistory(confirmCode: self.confirmCode)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] result in
            self?.delegate?.sendHistoryFinished(result: result)
        }).disposed(by: disposeBag)
    }
}
