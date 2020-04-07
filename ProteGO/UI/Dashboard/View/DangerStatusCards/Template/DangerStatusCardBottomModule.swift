import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DangerStatusCardBottomModule: UIView {

    var tapMoreEvent: ControlEvent<Void> {
        let tapObservable = tapGestureRecognizer.rx.event
            .map { _ in return () }
        return ControlEvent<Void>(events: tapObservable)
    }

    var contactButtonTapEvent: ControlEvent<Void> {
        return contactButton.rx.tap
    }

    private let descriptionFirstParagraphLabel = UILabel()

    private let descriptionSecondParagraphLabel = UILabel()

    private let contactButton = UIButton.rectButton(backgroundColor: .white)

    private let tapGestureRecognizer = UITapGestureRecognizer()

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(config: DangerStatusCardConfig,
                   buttonConfig: DangerStatusCardButtonConfig?,
                   secondParagraphConfig: DangerStatusCardSecondParagraphConfig?) {
        self.backgroundColor = config.color
        self.addCommonSubviews()
        self.setupCommonConstraints()
        self.setupDescriptionFirstParagraphLabel(text: config.firstParagraphText)

        if let secondParagraphConfig = secondParagraphConfig {
            self.addSubview(self.descriptionSecondParagraphLabel)
            self.setupSecondParagraphConstraints()
            self.descriptionSecondParagraphLabel.addGestureRecognizer(self.tapGestureRecognizer)
            self.setupDescriptionSecondParagraphLabel(
                textFunction: secondParagraphConfig.secondParagraphTextFunction,
                hereText: secondParagraphConfig.secondParagraphHereText)
        }

        if let buttonConfig = buttonConfig {
            self.addSubview(self.contactButton)
            self.setupButtonConstraints()
            self.setupContactButton(normalColor: buttonConfig.normalColor,
                                    highlightedColor: buttonConfig.highlightedColor,
                                    text: buttonConfig.title)
        }
    }

    private func addCommonSubviews() {
        self.addSubview(descriptionFirstParagraphLabel)
    }

    private func setupCommonConstraints() {
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

    private func setupDescriptionFirstParagraphLabel(text: String) {
        self.descriptionFirstParagraphLabel.configure(text: text, fontStyle: .bodySmall)
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
                value: Fonts.poppinsSemiBold(14).font,
                range: hereRange)

            self.descriptionSecondParagraphLabel.attributedText = attributedText
        }

        self.descriptionSecondParagraphLabel.textColor = .white
        self.descriptionSecondParagraphLabel.numberOfLines = 0
        self.descriptionSecondParagraphLabel.isUserInteractionEnabled = true
    }

    private func setupContactButton(normalColor: UIColor, highlightedColor: UIColor, text: String) {
        self.contactButton.setBackgroundColor(highlightedColor, forState: .highlighted)
        self.contactButton.setTitleColor(normalColor, for: .normal)
        self.contactButton.setTitleColor(.white, for: .highlighted)
        self.contactButton.setTitle(text, for: .normal)
    }
}
