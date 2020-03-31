import UIKit

final class RootViewController: UIViewController, CustomView {

    typealias ViewClass = RootView

    private enum Content {
        case onboarding, registration, dashboard
    }

    private var currentContentViewController: UIViewController?

    private let viewModel: RootViewModelType

    private let onboardingViewController: OnboardingViewController

    private let registrationViewController: RegistrationViewController

    private let dashboardViewController: DashboardViewController

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
        presentInitialContent()
    }

    private func setupDelegates() {
        registrationViewController.delegate = self
    }

    private func presentInitialContent() {
        present(content: .registration)
    }

    private func present(content: Content) {
        let viewControllerToPresent: UIViewController
        switch content {
        case .onboarding:
            viewControllerToPresent = onboardingViewController
        case .registration:
            viewControllerToPresent = registrationViewController
        case .dashboard:
            viewControllerToPresent = dashboardViewController
        }

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
}

extension RootViewController: RegistrationViewControllerDelegate {

    func didTapBackButton() {
        present(content: .onboarding)
    }

    func didFinishRegistration() {
        present(content: .dashboard)
    }
}
