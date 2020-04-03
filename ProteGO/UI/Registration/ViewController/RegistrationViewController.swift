import UIKit
import RxSwift

protocol RegistrationViewControllerDelegate: class {
    func didTapBackButton()
    func didFinishRegistration()
}

protocol DismissKeyboardDelegate: class {
    func dismissKeyboard()
}

final class RegistrationViewController: UIViewController, CustomView {

    typealias ViewClass = RegistrationView

    weak var delegate: RegistrationViewControllerDelegate?

    weak var dismissKeyboardDelegate: DismissKeyboardDelegate?

    private var currentContentViewController: UIViewController?

    private let viewModel: RegistrationViewModelType

    private let sendCodeViewController: RegistrationSendCodeViewController

    private let verifyCodeViewController: RegistrationVerifyCodeViewController

    let disposeBag = DisposeBag()

    init(viewModel: RegistrationViewModelType,
         sendCodeViewController: RegistrationSendCodeViewController,
         verifyCodeViewController: RegistrationVerifyCodeViewController) {
        self.viewModel = viewModel
        self.sendCodeViewController = sendCodeViewController
        self.verifyCodeViewController = verifyCodeViewController
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
        viewModel.bind(sendCodeViewController: sendCodeViewController)
        viewModel.bind(verifyCodeViewController: verifyCodeViewController)

        subscribeCurrentStep()
        subscribeDismissKeyboard()
    }

    func prepareBeforeAppearing() {
        viewModel.setInitialStep()
    }

    private func subscribeCurrentStep() {
        viewModel.currentStepObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] stepToPresent in
                self?.present(step: stepToPresent)
            }).disposed(by: disposeBag)

        viewModel.goBackObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.didTapBackButton()
            }).disposed(by: disposeBag)

        viewModel.registrationFinishedObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.didFinishRegistration()
            }).disposed(by: disposeBag)
    }

    private func subscribeDismissKeyboard() {
        viewModel.dismissKeyboardObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.dismissKeyboardDelegate?.dismissKeyboard()
            }).disposed(by: disposeBag)
    }

    private func present(step: RegistrationStep) {
        let viewControllerToPresent = prepareViewController(step: step)

        if let currentViewController = currentContentViewController {
            dismiss(viewController: currentViewController)
        }

        present(viewController: viewControllerToPresent)
    }

    private func prepareViewController(step: RegistrationStep) -> UIViewController {
        switch step {
        case .sendCode:
            sendCodeViewController.updateBeforeAppearing()
            dismissKeyboardDelegate = sendCodeViewController
            return sendCodeViewController
        case .verifyCode(let phoneNumber):
            verifyCodeViewController.updateBeforeAppearing(phoneNumber: phoneNumber)
            dismissKeyboardDelegate = verifyCodeViewController
            return verifyCodeViewController
        }
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
