import Foundation
import UIKit
import RxCocoa
import RxSwift

protocol SendHistoryConfirmModelType: class {
    var phoneId: String { get }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> { get }
}
