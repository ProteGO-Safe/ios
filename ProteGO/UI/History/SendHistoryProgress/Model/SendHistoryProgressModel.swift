import Foundation
import RxSwift
import RxCocoa

final class SendHistoryProgressModel: SendHistoryProgressModelType {

    var didFinishHistorySendingObservable: Observable<Result<Void, Error>> {
        return didSendHistorySubject.asObservable()
    }

    private let didSendHistorySubject = PublishSubject<Result<Void, Error>>()

    private var timer: Timer?

    init() {
        // TODO Implement history sending
        let timer = Timer.init(
            timeInterval: 1,
            repeats: false) { [weak self] _ in
                self?.didSendHistorySubject.onNext(.success(()))
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    deinit {
        self.timer?.invalidate()
    }
}
