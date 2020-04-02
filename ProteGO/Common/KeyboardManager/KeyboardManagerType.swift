import UIKit
import RxSwift

protocol KeyboardManagerType {

    var keyboardHeightWillChangeObservable: Observable<CGFloat> { get }
}
