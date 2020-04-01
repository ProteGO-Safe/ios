import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class GreenStatusCardView: DangerStatusCardView {
    init() {
        let config = DangerStatusCardConfig(
            color: Colors.bluishGreen,
            titleText: L10n.dashboardGreenStatusTitle,
            firstParagraphText: L10n.dashboardGreenStatusDescription)

        let paragraphConfig = DangerStatusCardSecondParagraphConfig(
            secondParagraphTextFunction: L10n.dashboardGreenStatusMoreInfoBtn,
            secondParagraphHereText: L10n.dashboardGreenStatusMoreInfoBtnHere)

        super.init(config: config, secondParagraphConfig: paragraphConfig)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
