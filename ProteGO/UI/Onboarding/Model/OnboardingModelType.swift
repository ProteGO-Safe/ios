import Foundation
import RxSwift

protocol OnboardingModelType {

    var currentStepObservable: Observable<OnboardingStep> { get }

    var didFinishOnboardingObservable: Observable<Void> { get }

    var backButtonVisibleObservable: Observable<Bool> { get }

    func nextStep()

    func previousStep()
}
