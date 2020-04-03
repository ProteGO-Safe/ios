import Foundation
import RxSwift

final class RootViewModel: RootViewModelType {

    var currentContentObservable: Observable<RootContent> {
        return model.currentContentObservable
    }

    private var model: RootModelType

    init(model: RootModelType) {
        self.model = model
    }

    func didFinishOnboarding() {
        model.didFinishOnboarding()
    }

    func didFinishRegistration() {
        model.didFinishRegistration()
    }

    func registrationDidTapBack() {
        model.registrationDidTapBack()
    }
}
