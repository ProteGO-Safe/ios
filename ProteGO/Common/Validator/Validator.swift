import Foundation
import RxSwift

final class Validator {
    private(set) var type: ValidationType

    init(type: ValidationType) {
        self.type = type
    }
    func validate(text: String) -> Result<Void, ValidationError> {
        let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
        return predicate.evaluate(with: text) ? .success(()) : .failure(type.error)
    }
}

extension ObservableType where Element == String {
    func validate(type: ValidationType) -> Observable<Result<Element, ValidationError>> {
        self
            .flatMap { element -> Observable<Result<Element, ValidationError>> in
                let validator = Validator(type: type)
                switch validator.validate(text: element) {
                case .success:
                    return Observable.just(.success(element))
                case let .failure(error):
                    return Observable.just(.failure(error))
                }
        }
    }
}
