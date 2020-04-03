import Foundation
import RxSwift

protocol RootModelType {

    var currentContentObservable: Observable<RootContent> { get }

    func didFinishOnboarding()

    func didFinishRegistration()

    func registrationDidTapBack()
}
