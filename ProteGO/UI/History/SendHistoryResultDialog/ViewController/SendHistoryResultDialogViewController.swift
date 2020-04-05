import UIKit
import RxSwift

final class SendHistoryResultDialogViewController: UIViewController, CustomView {

    typealias ViewClass = SendHistoryResultDialogView

    private let isSuccessAlert: Bool

    private let disposeBag: DisposeBag = DisposeBag()

    init(success: Bool) {
        self.isSuccessAlert = success

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ViewClass(success: self.isSuccessAlert)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindUIEvents()
    }

    private func bindUIEvents() {
          customView.closeButtonTapped.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
          }).disposed(by: disposeBag)

        customView.footerLabelTapped.subscribe(onNext: {
            if let url = URL(string: "mailto:\(L10n.sendDataAlertFooterEmail)") {
                UIApplication.shared.open(url)
            }
        }).disposed(by: disposeBag)
      }
}
