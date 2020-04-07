import Foundation
import RxSwift
import UIKit

class RegisteredBeaconIdsDebugViewController: UIViewController, CustomView {

    typealias ViewClass = RegisteredBeaconIdsDebugScreenView

    private let viewModel: RegisteredBeaconIdsDebugScreenViewModelType

    private let disposeBag: DisposeBag = DisposeBag()

    init(viewModel: RegisteredBeaconIdsDebugScreenViewModelType) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
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
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
}
