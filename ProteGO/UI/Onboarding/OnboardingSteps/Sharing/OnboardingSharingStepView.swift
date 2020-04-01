import UIKit

final class OnboardingSharingStepView: OnboardingStepView {

    init() {
        super.init(titleText: L10n.onboardingSharingTitle,
                   titleStyle: .subtitle,
                   descriptionText: L10n.onboardingSharingDescription)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
