import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import Valet

final class SendHistoryConfirmModel: SendHistoryConfirmModelType {
    var phoneId: String {
        guard let text = self.valet.string(forKey: Constants.KeychainKeys.userIdKey) else {
            return L10n.dashboardInfoIdPlacehloder
        }
        return String(text.prefix(Int(floor(Double(text.count) * 0.25))))
    }

    private let valet: Valet

    init(valet: Valet) {
        self.valet = valet
    }
}
