import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RedStatusCardView: DangerStatusCardView {
    init() {
        let config = DangerStatusCardConfig(
            color: UIColor(asset: Assets.copper),
            titleText: L10n.dashboardRedStatusTitle,
            firstParagraphText: L10n.dashboardRedStatusDescription)

        let buttonConfig = DangerStatusCardButtonConfig(title: L10n.dashboardRedStatusContactBtn,
                                                        normalColor: UIColor(asset: Assets.copper),
                                                        highlightedColor: UIColor(asset: Assets.brick))

        super.init(config: config, buttonConfig: buttonConfig)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
