import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class YellowStatusCardView: DangerStatusCardView {
    init() {
        let config = DangerStatusCardConfig(
            color: Colors.macaroniAndCheese,
            titleText: L10n.dashboardYellowStatusTitle,
            firstParagraphText: L10n.dashboardYellowStatusDescription)

        let paragraphConfig = DangerStatusCardSecondParagraphConfig(
            secondParagraphTextFunction: L10n.dashboardYellowMoreInfoBtn,
            secondParagraphHereText: L10n.dashboardYellowMoreInfoBtnHere)

        super.init(config: config, secondParagraphConfig: paragraphConfig)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
