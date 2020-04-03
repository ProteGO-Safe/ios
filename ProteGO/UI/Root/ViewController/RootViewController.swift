import UIKit
import RxSwift

final class RootViewController: UIViewController, CustomView {

    typealias ViewClass = RootView

    private var currentContentViewController: UIViewController?

    private let viewModel: RootViewModelType

    private let onboardingViewController: OnboardingViewController

    private let registrationViewController: RegistrationViewController

    private let dashboardViewController: DashboardViewController

    private let disposeBag = DisposeBag()

    init(viewModel: RootViewModelType,
         onboardingViewController: OnboardingViewController,
         registrationViewController: RegistrationViewController,
         dashboardViewController: DashboardViewController) {
        self.viewModel = viewModel
        self.onboardingViewController = onboardingViewController
        self.registrationViewController = registrationViewController
        self.dashboardViewController = dashboardViewController
        super.init(nibName: nil, bundle: nil)

        setupDelegates()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ViewClass()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeCurrentContent()
    }

    private func setupDelegates() {
        onboardingViewController.delegate = self
        registrationViewController.delegate = self
    }

    private func subscribeCurrentContent() {
        viewModel.currentContentObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] contentToPresent in
                self?.present(content: contentToPresent)
            }).disposed(by: disposeBag)
    }

    private func present(content: RootContent) {
        let viewControllerToPresent = prepareViewController(content: content)
        guard viewControllerToPresent != currentContentViewController else { return }

        if let currentViewController = currentContentViewController {
            dismiss(viewController: currentViewController)
        }

        present(viewController: viewControllerToPresent)
    }

    private func present(viewController: UIViewController) {
        addChild(viewController)
        customView.add(contentView: viewController.view)
        viewController.didMove(toParent: self)
        currentContentViewController = viewController
    }

    private func dismiss(viewController: UIViewController) {
        customView.remove(contentView: viewController.view)
        viewController.removeFromParent()
        viewController.willMove(toParent: nil)
        currentContentViewController = nil
    }

    private func prepareViewController(content: RootContent) -> UIViewController {
        switch content {
        case .onboarding:
            return onboardingViewController
        case .registration:
            registrationViewController.prepareBeforeAppearing()
            return registrationViewController
        case .dashboard:
            return dashboardViewController
        }
    }
}

extension RootViewController: OnboardingViewControllerDelegate {

    func didFinishOnboarding() {
        viewModel.didFinishOnboarding()
    }
}

extension RootViewController: RegistrationViewControllerDelegate {

    func didTapBackButton() {
        viewModel.registrationDidTapBack()
    }

    func didFinishRegistration() {
        viewModel.didFinishRegistration()
    }
}
