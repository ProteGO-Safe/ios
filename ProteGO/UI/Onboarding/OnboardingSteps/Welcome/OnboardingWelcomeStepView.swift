import UIKit

final class OnboardingWelcomeStepView: OnboardingStepView {

    init() {
        super.init(titleText: L10n.onboardingHelloTitle,
                   titleStyle: .headline,
                   descriptionText: L10n.onboardingHelloDescription)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
