import UIKit
import RxSwift

typealias SendHistoryConfirmViewControllerBuilder = () -> SendHistoryConfirmViewController

protocol SendHistoryConfirmViewControllerDelegate: class {
    func sendHistoryFinished(result: Result<Void, Error>)
}

final class SendHistoryConfirmViewController: UIViewController, CustomView {

    typealias ViewClass = SendHistoryConfirmView

    weak var delegate: SendHistoryConfirmViewControllerDelegate?

    private let viewModel: SendHistoryConfirmViewModelType

    private let sendHistoryProgressViewControllerBuilder: SendHistoryProgressViewControllerBuilder

    private let disposeBag: DisposeBag = DisposeBag()

    init(viewModel: SendHistoryConfirmViewModelType,
         sendHistoryProgressViewControllerBuilder: @escaping SendHistoryProgressViewControllerBuilder) {
        self.viewModel = viewModel
        self.sendHistoryProgressViewControllerBuilder = sendHistoryProgressViewControllerBuilder

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
        customView.backButtonTapped.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        customView.sendHistoryButtonTapped.subscribe(onNext: { [weak self] in
            guard let self = self else {
                return
            }

            let alert = UIAlertController(title: L10n.sendDataConfirmationAlertTitle,
                                          message: L10n.sendDataConfirmationAlertMessage,
                                          preferredStyle: UIAlertController.Style.alert)

            let sendHandler = { (_: UIAlertAction) in
                alert.dismiss(animated: true) {
                    let sendHistoryProgressViewController = self.sendHistoryProgressViewControllerBuilder()
                    sendHistoryProgressViewController.delegate = self
                    self.navigationController?.pushViewController(sendHistoryProgressViewController, animated: true)
                }
            }

            let cancelHandler = { (_: UIAlertAction) in
                alert.dismiss(animated: true)
            }

            alert.addAction(UIAlertAction(title: L10n.sendDataConfirmationAlertSendBtn, style: UIAlertAction.Style.default,
                                          handler: sendHandler))
            alert.addAction(UIAlertAction(title: L10n.sendDataConfirmationAlertCancelBtn, style: UIAlertAction.Style.cancel,
                                          handler: cancelHandler))
            self.present(alert, animated: true)

        }).disposed(by: disposeBag)
    }
}

extension SendHistoryConfirmViewController: SendHistoryProgressViewControllerDelegate {
    func sendHistoryFinished(result: Result<Void, Error>) {
        self.delegate?.sendHistoryFinished(result: result)
    }
}
