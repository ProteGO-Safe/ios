import Foundation
import RxSwift

protocol OnboardingViewModelType {

    var currentStepObservable: Observable<OnboardingStep> { get }

    var didFinishOnboardingObservable: Observable<Void> { get }

    func bind(view: OnboardingView)
}
