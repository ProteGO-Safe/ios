import UIKit
import RxSwift

typealias HistoryOverviewViewControllerBuilder = () -> HistoryOverviewViewController

final class DashboardViewController: UIViewController, CustomView {

    typealias ViewClass = DashboardView

    private let viewModel: DashboardViewModelType

    private let disposeBag: DisposeBag = DisposeBag()

    private let historyOverviewBuilder: HistoryOverviewViewControllerBuilder

    init(viewModel: DashboardViewModelType, historyOverViewBuilder: @escaping HistoryOverviewViewControllerBuilder) {
        self.viewModel = viewModel
        self.historyOverviewBuilder = historyOverViewBuilder

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.updateCurrentDangerStatus()
    }

    private func bindUIEvents() {
        customView.greenStatusTapMoreEvent.subscribe(onNext: {
            logger.debug("Green more tapped")
        }).disposed(by: disposeBag)

        customView.yellowStatusTapMoreEvent.subscribe(onNext: {
            logger.debug("Yellow more tapped")
        }).disposed(by: disposeBag)

        customView.redStatusContactButtonTappedEvent.subscribe(onNext: {
            logger.debug("Red contact button tapped")
        }).disposed(by: disposeBag)

        customView.greenGeneralRecommendationsTapMoreEvent.subscribe(onNext: {
            logger.debug("Green more recommended tapped")
        }).disposed(by: disposeBag)

        customView.yellowGeneralRecommendationsTapMoreEvent.subscribe(onNext: {
            logger.debug("Yellow more recommended tapped")
        }).disposed(by: disposeBag)

        customView.redGeneralRecommendationsTapMoreEvent.subscribe(onNext: {
            logger.debug("Red more recommended tapped")
        }).disposed(by: disposeBag)

        customView.hamburgerButtonTapEvent.subscribe(onNext: { [weak self] in
            guard let self = self else {
                return
            }
            let historyOverviewViewController = self.historyOverviewBuilder()
            historyOverviewViewController.modalPresentationStyle = .fullScreen
            self.present(historyOverviewViewController, animated: true)
        }).disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // TODO: This shouldn't be here, I guess that it's working because of the small delay between calling dispatch
        // and calling contents of this clojure. Without dispatch frame of the internal stack view isn't set
        DispatchQueue.main.async { [weak self] in
            self?.customView.updateScrollViewContentSize()
        }
    }
}
