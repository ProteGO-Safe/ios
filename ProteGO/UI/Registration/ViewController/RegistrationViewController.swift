import UIKit
import RxSwift

protocol RegistrationViewControllerDelegate: class {
    func didTapBackButton()
    func didFinishRegistration()
}

final class RegistrationViewController: UIViewController, CustomView {

    typealias ViewClass = RegistrationView

    weak var delegate: RegistrationViewControllerDelegate?

    private enum Content {
        case sendCode, verifyCode
    }

    private var currentContent: Content?

    private var currentContentViewController: UIViewController?

    private let sendCodeViewController: SendCodeViewController

    private let verifyCodeViewController: VerifyCodeViewController

    let disposeBag = DisposeBag()

    init(sendCodeViewController: SendCodeViewController,
         verifyCodeViewController: VerifyCodeViewController) {
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
        subscribeStepFinished()
        subscribeBackButtonTap()
        presentIntialContent()
    }

    private func subscribeBackButtonTap() {
        customView.backButtonTapEvent.subscribe(onNext: { [weak self] _ in
            self?.previousStep()
        }).disposed(by: disposeBag)
    }

    private func subscribeStepFinished() {
        sendCodeViewController.stepFinishedObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.nextStep()
        }).disposed(by: disposeBag)

        verifyCodeViewController.stepFinishedObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.didFinishRegistration()
        }).disposed(by: disposeBag)
    }

    private func presentIntialContent() {
        present(content: .sendCode)
    }

    private func nextStep() {
        if currentContent == .sendCode {
            present(content: .verifyCode)
        }
    }

    private func previousStep() {
        if currentContent == .verifyCode {
            present(content: .sendCode)
        } else {
            delegate?.didTapBackButton()
        }
    }

    private func present(content: Content) {
        let viewControllerToPresent: UIViewController
        switch content {
        case .sendCode:
            viewControllerToPresent = sendCodeViewController
        case .verifyCode:
            viewControllerToPresent = verifyCodeViewController
        }

        if let currentViewController = currentContentViewController {
            dismiss(viewController: currentViewController)
        }

        present(viewController: viewControllerToPresent)
        currentContent = content
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
