import UIKit

final class StatusDescriptionsContainerView: UIView {

    private let greenStatusView = StatusDesciptionView(color: Colors.bluishGreen, text: L10n.onboardingGreenDescription)

    private let yellowStatusView = StatusDesciptionView(color: Colors.macaroniAndCheese,
                                                        text: L10n.onboardingYellowDescription)

    private let redStatusView = StatusDesciptionView(color: Colors.copper, text: L10n.onboardingRedDescription)

    init() {
        super.init(frame: .zero)
        addSubviews()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubviews([greenStatusView, yellowStatusView, redStatusView])
    }

    private func setConstraints() {
        greenStatusView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        yellowStatusView.snp.makeConstraints {
            $0.top.equalTo(greenStatusView.snp.bottom).offset(0.018 * UIScreen.height)
            $0.leading.trailing.equalToSuperview()
        }

        redStatusView.snp.makeConstraints {
            $0.top.equalTo(yellowStatusView.snp.bottom).offset(0.018 * UIScreen.height)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
