import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import Valet

final class SendHistoryConfirmModel: SendHistoryConfirmModelType {
    var phoneId: String {
        guard let text = self.keychainProvider.string(forKey: Constants.KeychainKeys.userIdKey) else {
            return L10n.dashboardInfoIdPlacehloder
        }
        return text.prefix(withLengthRatio: Constants.HistorySend.userIdPrefixLengthRatio)
    }

    var keyboardHeightWillChangeObservable: Observable<CGFloat> {
        keyboardManager.keyboardHeightWillChangeObservable
    }

    private let keyboardManager: KeyboardManagerType

    private let keychainProvider: KeychainProviderType

    init(keychainProvider: KeychainProviderType, keyboardManager: KeyboardManagerType) {
        self.keychainProvider = keychainProvider
        self.keyboardManager = keyboardManager
    }
}
