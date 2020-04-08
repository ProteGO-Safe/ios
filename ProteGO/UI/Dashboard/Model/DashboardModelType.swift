import Foundation
import RxSwift
import RxCocoa

protocol DashboardModelType: class {
    var currentStatus: BehaviorRelay<DangerStatus> { get }
}
