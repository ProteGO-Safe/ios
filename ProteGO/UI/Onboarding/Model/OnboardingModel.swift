import Foundation
import RxSwift

enum OnboardingStep {
    case welcome, status, bluetooth, sharing
}

final class OnboardingModel: OnboardingModelType {

    var currentStepObservable: Observable<OnboardingStep> {
        return currentStepSubject.asObservable()
    }

    var backButtonVisibleObservable: Observable<Bool> {
        return currentStepSubject.map { [weak self] currentStep in
            return currentStep != self?.steps.first
        }
    }

    var didFinishOnboardingObservable: Observable<Void> {
        return didFinishOnboardingSubject.asObservable()
    }

    private lazy var currentStepSubject = BehaviorSubject<OnboardingStep>(value: currentStep)

    private var didFinishOnboardingSubject = PublishSubject<Void>()

    private var currentStep: OnboardingStep = .welcome {
        didSet {
            currentStepSubject.onNext(currentStep)
        }
    }

    private let steps: [OnboardingStep] = [.welcome, .status, .bluetooth, .sharing]

    func nextStep() {
        guard let index = steps.firstIndex(of: currentStep) else { return }

        guard index + 1 < steps.count else {
            didFinishOnboardingSubject.onNext(())
            return
        }
        currentStep = steps[index + 1]
    }

    func previousStep() {
        guard let index = steps.firstIndex(of: currentStep), index > 0 else { return }
        currentStep = steps[index - 1]
    }
}
