import UIKit
import RxSwift

protocol HistoryOverviewViewControllerDelegate: class {
    func sendHistoryFinished(result: Result<Void, Error>)
}

final class HistoryOverviewViewController: UIViewController, CustomView {

    typealias ViewClass = HistoryOverviewView

    weak var delegate: HistoryOverviewViewControllerDelegate?

    private let viewModel: HistoryOverviewViewModelType

    private let sendHistoryConfirmViewControllerBuilder: SendHistoryConfirmViewControllerBuilder

    private let disposeBag: DisposeBag = DisposeBag()

    init(viewModel: HistoryOverviewViewModelType,
         sendHistoryConfirmViewControllerBuilder: @escaping SendHistoryConfirmViewControllerBuilder) {
        self.viewModel = viewModel
        self.sendHistoryConfirmViewControllerBuilder = sendHistoryConfirmViewControllerBuilder

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

        customView.sendHistoryButtonTapped.subscribe(onNext: { [weak self] in
            guard let self = self else {
                logger.error("Instance deallocated file: \(#file), line: \(#line)")
                return
            }

            let sendHistoryConfirmViewController = self.sendHistoryConfirmViewControllerBuilder()
            sendHistoryConfirmViewController.delegate = self
            self.navigationController?.pushViewController(sendHistoryConfirmViewController, animated: true)
        }).disposed(by: disposeBag)

        customView.termsOfUseButtonTapped.subscribe(onNext: {
            logger.debug("terms of use tapped")
        }).disposed(by: disposeBag)

        customView.contactUsEmailButtonTapped.subscribe(onNext: {
            UIApplication.shared.open(URL(fileURLWithPath: "mailto:\(L10n.dashboardInfoContactUsEmail)"))
        }).disposed(by: disposeBag)
    }
}

extension HistoryOverviewViewController: SendHistoryConfirmViewControllerDelegate {
    func sendHistoryFinished(result: Result<Void, Error>) {
        self.delegate?.sendHistoryFinished(result: result)
    }
}
