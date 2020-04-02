import UIKit
import RxSwift

final class HistoryOverviewViewController: UIViewController, CustomView {

    typealias ViewClass = HistoryOverviewView

    private let viewModel: HistoryOverviewViewModelType

    private let disposeBag: DisposeBag = DisposeBag()

    init(viewModel: HistoryOverviewViewModelType) {
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
        self.bindUIEvents()
    }

    private func bindUIEvents() {
        customView.closeButtonTapped.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)

        customView.termsOfUseButtonTapped.subscribe(onNext: {
            logger.debug("terms of use tapped")
        }).disposed(by: disposeBag)

        customView.contactUsEmailButtonTapped.subscribe(onNext: {
            UIApplication.shared.open(URL(fileURLWithPath: "mailto:\(L10n.dashboardInfoContactUsEmail)"))
        }).disposed(by: disposeBag)
    }
}
