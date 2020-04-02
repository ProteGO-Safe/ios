import UIKit

final class OnboardingStatusStepView: OnboardingStepView {

    init() {
        super.init(titleText: L10n.onboardingStatusTitle,
                   titleStyle: .subtitle,
                   descriptionText: L10n.onboardingStatusDescription,
                   bottomView: StatusDescriptionsContainerView())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
