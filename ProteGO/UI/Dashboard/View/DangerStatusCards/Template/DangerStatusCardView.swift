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
        let tapObservable = tapGestureRecognizer.rx.event
            .map { _ in return () }
        return ControlEvent<Void>(events: tapObservable)
    }

    var contactButtonTapEvent: ControlEvent<Void> {
        return contactButton.rx.tap
    }

    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()

    private let topContainerView = DangerStatusCardTopModule()

    private let bottomContainerView = UIView()

    private let descriptionFirstParagraphLabel = UILabel()

    private let descriptionSecondParagraphLabel = UILabel()

    private let contactButton = UIButton()

    private let tapGestureRecognizer = UITapGestureRecognizer()

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

        self.topContainerView.configure(config: config)

        self.setupBottomContainerViewBuilder(color: config.color)
        self.setupDescriptionFirstParagraphLabel(text: config.firstParagraphText)

        if let secondParagraphConfig = secondParagraphConfig {
            self.bottomContainerView.addSubview(self.descriptionSecondParagraphLabel)
            self.setupSecondParagraphConstraints()
            self.descriptionSecondParagraphLabel.addGestureRecognizer(self.tapGestureRecognizer)
            self.setupDescriptionSecondParagraphLabel(
                textFunction: secondParagraphConfig.secondParagraphTextFunction,
                hereText: secondParagraphConfig.secondParagraphHereText)
        }

        if let buttonConfig = buttonConfig {
            self.bottomContainerView.addSubview(self.contactButton)
            self.setupButtonConstraints()
            self.setupContactButton(color: config.color, text: buttonConfig.buttonTitle)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addCommonSubviews() {
        self.addSubviews([containerStackView])
        self.containerStackView.addArrangedSubview(topContainerView)
        self.containerStackView.addArrangedSubview(bottomContainerView)

        self.bottomContainerView.addSubview(descriptionFirstParagraphLabel)
    }

    private func setupCommonConstraints() {
        self.containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.descriptionFirstParagraphLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
            $0.top.equalToSuperview().offset(20)
        }
    }

    private func setupSecondParagraphConstraints() {
        self.descriptionSecondParagraphLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
            $0.top.equalTo(self.descriptionFirstParagraphLabel.snp.bottom).offset(22)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    private func setupButtonConstraints() {
        self.contactButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
            $0.top.equalTo(self.descriptionFirstParagraphLabel.snp.bottom).offset(14)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupBottomContainerViewBuilder(color: UIColor) {
        self.bottomContainerView.backgroundColor = color
    }

    private func setupDescriptionFirstParagraphLabel(text: String) {
        self.descriptionFirstParagraphLabel.text = text
        self.descriptionFirstParagraphLabel.font = Fonts.poppinsMedium(14).font
        self.descriptionFirstParagraphLabel.textColor = .white
        self.descriptionFirstParagraphLabel.numberOfLines = 0
    }

    private func setupDescriptionSecondParagraphLabel(textFunction: (String) -> String, hereText: String) {
        let text = textFunction(hereText)

        if let range = text.range(of: hereText) {
            let attributedText = NSMutableAttributedString.init(string: text)
            let wholeLabelRange = NSRange(location: 0, length: attributedText.length)
            let hereRange = NSRange(range, in: text)
            attributedText.addAttribute(
                NSAttributedString.Key.font,
                value: Fonts.poppinsMedium(14).font,
                range: wholeLabelRange)
            attributedText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: 1,
                range: hereRange)
            attributedText.addAttribute(
                NSAttributedString.Key.font,
                value: Fonts.poppinsBold(14).font,
                range: hereRange)

            self.descriptionSecondParagraphLabel.attributedText = attributedText
        }

        self.descriptionSecondParagraphLabel.textColor = .white
        self.descriptionSecondParagraphLabel.numberOfLines = 0
        self.descriptionSecondParagraphLabel.isUserInteractionEnabled = true
    }

    private func setupContactButton(color: UIColor, text: String) {
        self.contactButton.setBackgroundColor(.white, forState: .normal)
        self.contactButton.setTitleColor(color, for: .normal)
        self.contactButton.setTitle(text, for: .normal)
        self.contactButton.titleLabel?.font = Fonts.poppinsMedium(16).font
        self.contactButton.layer.cornerRadius = 4
        self.contactButton.clipsToBounds = true
    }
}
