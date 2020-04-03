import Foundation
import RxCocoa
import RxSwift

protocol HistoryOverviewModelType: class {
    var phoneId: String { get }

    var historyLastDate: BehaviorRelay<Date> { get }

    var lastSeenDevicesCount: BehaviorRelay<Int> { get }
}
