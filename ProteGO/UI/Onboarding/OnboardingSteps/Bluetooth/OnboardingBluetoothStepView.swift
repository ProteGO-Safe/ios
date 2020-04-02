import UIKit

final class OnboardingBluetoothStepView: OnboardingStepView {

    init() {
        super.init(titleText: L10n.onboardingBluetoothTitle,
                   titleStyle: .subtitle,
                   descriptionText: L10n.onboardingBluetoothDescription)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
