import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct DangerStatusCardConfig {
    let color: UIColor
    let titleText: String
    let firstParagraphText: String
}

struct DangerStatusCardSecondParagraphConfig {
    let secondParagraphTextFunction: (String) -> String
    let secondParagraphHereText: String
}

struct DangerStatusCardButtonConfig {
    let buttonTitle: String
}

class DangerStatusCardView: UIView {

    var tapMoreEvent: ControlEvent<Void> {
        return self.bottomMobileView.tapMoreEvent
    }

    var contactButtonTapEvent: ControlEvent<Void> {
        return self.bottomMobileView.contactButtonTapEvent
    }

    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()

    private let topModuleView = DangerStatusCardTopModule()

    private let bottomMobileView = DangerStatusCardBottomModule()

    init(config: DangerStatusCardConfig, buttonConfig: DangerStatusCardButtonConfig) {
        super.init(frame: .zero)
        self.configure(with: config, buttonConfig: buttonConfig, secondParagraphConfig: nil)
    }

    init(config: DangerStatusCardConfig, secondParagraphConfig: DangerStatusCardSecondParagraphConfig) {
        super.init(frame: .zero)
        self.configure(with: config, buttonConfig: nil, secondParagraphConfig: secondParagraphConfig)
    }

    private func configure(with config: DangerStatusCardConfig,
                           buttonConfig: DangerStatusCardButtonConfig?,
                           secondParagraphConfig: DangerStatusCardSecondParagraphConfig?) {
        backgroundColor = .white
        self.layer.borderColor = config.color.cgColor
        self.layer.borderWidth = 1

        self.addCommonSubviews()
        self.setupCommonConstraints()

        self.topModuleView.configure(config: config)
        self.bottomMobileView.configure(config: config,
                                           buttonConfig: buttonConfig,
                                           secondParagraphConfig: secondParagraphConfig)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addCommonSubviews() {
        self.addSubviews([containerStackView])
        self.containerStackView.addArrangedSubview(topModuleView)
        self.containerStackView.addArrangedSubview(bottomMobileView)
    }

    private func setupCommonConstraints() {
        self.containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
