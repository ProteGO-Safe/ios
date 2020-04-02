import UIKit
import RxSwift

protocol OnboardingViewControllerDelegate: class {
    func didFinishOnboarding()
}

final class OnboardingViewController: UIViewController, CustomView {

    typealias ViewClass = OnboardingView

    weak var delegate: OnboardingViewControllerDelegate?

    private let viewModel: OnboardingViewModelType

    private let disposeBag = DisposeBag()

    init(viewModel: OnboardingViewModelType) {
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
        subscribeCurrentStep()
    }

    private func subscribeCurrentStep() {
        viewModel.currentStepObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] stepToPresent in
                self?.present(step: stepToPresent)
            }).disposed(by: disposeBag)

        viewModel.didFinishOnboardingObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.didFinishOnboarding()
            }).disposed(by: disposeBag)
    }

    private func present(step: OnboardingStep) {
        customView.removeContentView()
        customView.add(contentView: contentView(step: step))
        customView.set(bannerImage: bannerImage(step: step))
    }

    private func contentView(step: OnboardingStep) -> OnboardingStepView {
        switch step {
        case .welcome:
            return OnboardingWelcomeStepView()
        case .status:
            return OnboardingStatusStepView()
        case .bluetooth:
            return OnboardingBluetoothStepView()
        case .sharing:
            return OnboardingSharingStepView()
        }
    }

    private func bannerImage(step: OnboardingStep) -> UIImage {
        switch step {
        case .welcome:
            return Images.onboardingHello
        case .status:
            return Images.onboardingStatus
        case .bluetooth:
            return Images.onboardingBluetooth
        case .sharing:
            return Images.onboardingSharing
        }
    }
}
