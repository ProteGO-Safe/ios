import Foundation
import RxSwift
import RxCocoa

final class OnboardingViewModel: OnboardingViewModelType {

    var currentStepObservable: Observable<OnboardingStep> {
        return model.currentStepObservable
    }

    var didFinishOnboardingObservable: Observable<Void> {
        return model.didFinishOnboardingObservable
    }

    private var backButtonVisibleDriver: Driver<Bool> {
        return model.backButtonVisibleObservable
            .asDriver(onErrorJustReturn: true)
    }

    private let model: OnboardingModelType

    private let disposeBag = DisposeBag()

    init(model: OnboardingModelType) {
        self.model = model
    }

    func bind(view: OnboardingView) {
        view.backButtonTapEvent.subscribe(onNext: { [weak self] _ in
            self?.model.previousStep()
        }).disposed(by: disposeBag)

        view.nextButtonTapEvent.subscribe(onNext: { [weak self] _ in
            self?.model.nextStep()
        }).disposed(by: disposeBag)

        backButtonVisibleDriver.drive(view.backButtonVisibleBinder).disposed(by: disposeBag)
    }
}
