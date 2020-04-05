import Foundation
import RxSwift

final class Validator {
    private(set) var type: ValidationType

    init(type: ValidationType) {
        self.type = type
    }
    func isValid(text: String?) -> Result<Bool, ValidationError> {
        let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
        return predicate.evaluate(with: text) ? .success(true) : .failure(type.error)
    }
}

extension ObservableType {
    func validate(text: String, type: ValidationType) -> Observable<Element> {
        self
            .flatMap { element -> Observable<Element> in
                let validator = Validator(type: type)
                switch validator.isValid(text: text) {
                case .success:
                    return Observable.just(element)
                case let .failure(error):
                    return Observable.error(error)
                }
        }
    }
}
