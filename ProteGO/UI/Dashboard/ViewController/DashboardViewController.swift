import UIKit
import RxSwift

typealias HistoryRootViewControllerBuilder = () -> HistoryRootViewController

final class DashboardViewController: UIViewController, CustomView {

    typealias ViewClass = DashboardView

    private let viewModel: DashboardViewModelType

    private let disposeBag: DisposeBag = DisposeBag()

    private let historyRootBuilder: HistoryRootViewControllerBuilder

    init(viewModel: DashboardViewModelType, historyRootBuilder: @escaping HistoryRootViewControllerBuilder) {
        self.viewModel = viewModel
        self.historyRootBuilder = historyRootBuilder

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
        customView.greenStatusTapMoreEvent.subscribe(onNext: {
            if let url = URL(string: L10n.dashboardMoreInfoBtnLink) {
                UIApplication.shared.open(url)
            }
        }).disposed(by: disposeBag)

        customView.yellowStatusTapMoreEvent.subscribe(onNext: {
            if let url = URL(string: L10n.dashboardMoreInfoBtnLink) {
                UIApplication.shared.open(url)
            }
        }).disposed(by: disposeBag)

        customView.redStatusContactButtonTappedEvent.subscribe(onNext: {
            if let url = URL(string: "tel://\(L10n.dashboardRedStatusContactBtnPhone)") {
                UIApplication.shared.open(url)
            }
        }).disposed(by: disposeBag)

        customView.hamburgerButtonTapEvent.subscribe(onNext: { [weak self] in
            guard let self = self else {
                return
            }
            let historyRootViewController = self.historyRootBuilder()
            historyRootViewController.historyRootViewControllerDelegate = self
            historyRootViewController.modalPresentationStyle = .fullScreen
            self.present(historyRootViewController, animated: true)
        }).disposed(by: disposeBag)
    }
}

extension DashboardViewController: HistoryRootViewControllerDelegate {
    func sendHistoryFinished(result: Result<Void, Error>) {
        let resultDialog: UIViewController
        switch result {
        case .success:
            resultDialog = SendHistoryResultDialogViewController(success: true)
        case .failure:
            resultDialog = SendHistoryResultDialogViewController(success: false)
        }

        resultDialog.modalPresentationStyle = .overCurrentContext
        resultDialog.modalTransitionStyle = .crossDissolve
        self.present(resultDialog, animated: true)
    }
}
