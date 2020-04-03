import Foundation
import RxSwift

protocol RootViewModelType {

    var currentContentObservable: Observable<RootContent> { get }

    func didFinishOnboarding()

    func didFinishRegistration()

    func registrationDidTapBack()
}
