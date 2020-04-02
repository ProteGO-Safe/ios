import UIKit
import RxSwift

final class KeyboardManager: KeyboardManagerType {

    var keyboardHeightWillChangeObservable: Observable<CGFloat> {
        return notificationCenter.rx
            .notification(UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { [weak self] notification in
                return self?.keyboardHeight(from: notification)
        }
    }

    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    private func keyboardHeight(from keyboardFrameWillChangeNotification: Notification) -> CGFloat {
        guard let keyboardFrameValue =
            keyboardFrameWillChangeNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return 0
        }
        let keyboardFrameCgRect = keyboardFrameValue.cgRectValue
        let keyboardHeight = UIScreen.main.bounds.height - keyboardFrameCgRect.origin.y
        return keyboardHeight
    }
}
