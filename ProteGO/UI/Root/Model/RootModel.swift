import Foundation
import RxSwift

enum RootContent: String {
    case onboarding, registration, dashboard
}

final class RootModel: RootModelType {

    var currentContentObservable: Observable<RootContent> {
        return currentContentSubject.asObservable()
    }

    private lazy var currentContentSubject = BehaviorSubject<RootContent>(value: currentContent)

    private var currentContent: RootContent = .dashboard {
        didSet {
            currentContentSubject.onNext(currentContent)
        }
    }

    private let registrationManager: RegistrationManagerType

    private let defaultsService: DefaultsServiceType

    let disposeBag = DisposeBag()

    init(registrationManager: RegistrationManagerType,
         defaultsService: DefaultsServiceType) {
        self.registrationManager = registrationManager
        self.defaultsService = defaultsService

        subscribeIsUserRegistered()
        setInitialContent()
    }

    func didFinishOnboarding() {
        defaultsService.finishedOnboarding = true
        currentContent = .registration
    }

    func didFinishRegistration() {
        currentContent = .dashboard
    }

    func registrationDidTapBack() {
        currentContent = .onboarding
    }

    private func setInitialContent() {
        if DebugMenu.assign(DebugMenu.forceInitialRootContent) {
            if let debugContent = RootContent(rawValue: DebugMenu.assign(DebugMenu.initialRootContentValue).value) {
                currentContent = debugContent
            }
        } else {
            if defaultsService.finishedOnboarding == false {
                currentContent = .onboarding
            } else if registrationManager.isUserRegistered == false {
                currentContent = .registration
            } else {
                currentContent = .dashboard
            }
        }
    }

    private func subscribeIsUserRegistered() {
        registrationManager.isUserRegisteredObservable.subscribe(onNext: { [weak self] isRegistered in
            if !isRegistered {
                self?.currentContent = .registration
            }
        }).disposed(by: disposeBag)
    }
}
