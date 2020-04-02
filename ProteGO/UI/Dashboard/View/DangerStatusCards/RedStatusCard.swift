import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RedStatusCardView: DangerStatusCardView {
    init() {
        let config = DangerStatusCardConfig(
            color: Colors.copper,
            titleText: L10n.dashboardRedStatusTitle,
            firstParagraphText: L10n.dashboardRedStatusDescription)

        let buttonConfig = DangerStatusCardButtonConfig(buttonTitle: L10n.dashboardRedStatusContactBtn)

        super.init(config: config, buttonConfig: buttonConfig)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
