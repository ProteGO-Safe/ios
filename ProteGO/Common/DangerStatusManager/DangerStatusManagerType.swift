import Foundation
import RxSwift
import RxCocoa

protocol DangerStatusManagerType: class {
    var currentStatus: BehaviorRelay<DangerStatus> { get }

    func update(with status: DangerStatus)
}
