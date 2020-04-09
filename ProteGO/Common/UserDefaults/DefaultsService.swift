import Foundation
import RxSwift

final class DefaultsService: DefaultsServiceType {

    public var finishedFirstAppLaunch: Bool {
        get {
            return value(forKey: .finishedFirstAppLaunch) as? Bool ?? false
        }
        set {
            save(value: newValue, key: .finishedFirstAppLaunch)
        }
    }

    public var finishedOnboarding: Bool {
        get {
            return value(forKey: .finishedOnboarding) as? Bool ?? false
        }
        set {
            save(value: newValue, key: .finishedOnboarding)
        }
    }

    func valueChangeObservable<T>(key: DefaultsKey) -> Observable<T> {
        return valueChangeSubject
            .filter { $0 == key }
            .compactMap { [weak self] _ in
                return self?.value(forKey: key) as? T
            }
    }

    private let userDefaults: UserDefaults = .standard

    private let valueChangeSubject = PublishSubject<DefaultsKey>()

    private func value(forKey key: DefaultsKey) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }

    private func save(value: Any?, key: DefaultsKey) {
        userDefaults.set(value, forKey: key.rawValue)
        valueChangeSubject.onNext(key)
    }

}
