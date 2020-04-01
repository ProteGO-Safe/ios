import UIKit
import RxCocoa

final class NavigationButtonsView: UIView {

    var backButtonVisibleBinder: Binder<Bool> {
        return Binder<Bool>(backButton) { button, visible in
            button.isHidden = !visible
        }
    }

    var backButtonTapEvent: ControlEvent<Void> {
        return backButton.rx.tap
    }

    var nextButtonTapEvent: ControlEvent<Void> {
        return nextButton.rx.tap
    }

    private let backButton = UIButton.rectButton(text: L10n.onboardingBackBtn,
                                                 textColor: Colors.bluishGreen,
                                                 backgroundColor: .white, borderColor: Colors.bluishGreen)

    private let nextButton = UIButton.rectButton(text: L10n.onboardingNextBtn)

    init() {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubviews([backButton, nextButton])
    }

    private func setupConstraints() {

        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-24)
            $0.width.equalTo(96)
            $0.height.equalTo(48)
        }

        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-24)
            $0.width.height.equalTo(backButton)
        }
    }
}
