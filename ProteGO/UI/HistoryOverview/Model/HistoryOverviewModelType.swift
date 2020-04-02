import Foundation
import RxCocoa
import RxSwift

protocol HistoryOverviewModelType: class {
    var phoneId: BehaviorRelay<String> { get }

    var historyLastDate: BehaviorRelay<String> { get }

    var lastSeenDevicesCount: BehaviorRelay<String> { get }
}
