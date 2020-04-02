import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct GeneralRecommendationsCardConfig {
    let title: String
    let paragraphs: [String]
    let footerTextFunction: (String) -> String
    let footerHereText: String
}

class GeneralRecommendationsCard: UIView {

    var tapMoreEvent: ControlEvent<Void> {
        let tapObservable = tapGestureRecognizer.rx.event
            .map { _ in return () }
        return ControlEvent<Void>(events: tapObservable)
    }

    private let generalContainerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 11
        return view
    }()

    private let paragraphsContainerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 11
        return view
    }()

    private let titleLabel = UILabel()

    private var paragraphLabels: [UILabel] = []

    private let footerLabel = UILabel()

    private let tapGestureRecognizer = UITapGestureRecognizer()

    init(config: GeneralRecommendationsCardConfig) {
        super.init(frame: .zero)
        backgroundColor = .white
        self.layer.borderColor = Colors.greyish.cgColor
        self.layer.borderWidth = 1

        self.addSubviews()
        self.setupConstraints()

        self.setupTitleLabel(text: config.title)
        self.setupFooterLabel(textFunction: config.footerTextFunction, hereText: config.footerHereText)
        self.setupParagraphs(paragraphTexts: config.paragraphs)
        self.footerLabel.addGestureRecognizer(self.tapGestureRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.addSubview(self.generalContainerStackView)
        self.generalContainerStackView.addArrangedSubviews([
            self.titleLabel,
            self.paragraphsContainerStackView,
            self.footerLabel])
    }

    private func setupConstraints() {
        self.generalContainerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.bottom.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
        }
    }

    private func setupTitleLabel(text: String) {
        self.titleLabel.configure(text: text, fontStyle: .subtitle)
        self.titleLabel.numberOfLines = 0
    }

    private func setupFooterLabel(textFunction: (String) -> String, hereText: String) {
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

            self.footerLabel.attributedText = attributedText
        }

        self.footerLabel.textColor = Colors.greyishBrown
        self.footerLabel.numberOfLines = 0
        self.footerLabel.isUserInteractionEnabled = true
    }

    func setupParagraphs(paragraphTexts: [String]) {
        for text in paragraphTexts {
            let label = UILabel()
            label.font = Fonts.poppinsMedium(14).font
            label.textColor = Colors.greyishBrown
            label.numberOfLines = 0

            let image = Images.generalRecommendationExclamationMark
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: (label.font.capHeight - image.size.height).rounded() / 2,
                                       width: image.size.width, height: image.size.height)
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(attachment: attachment))
            attributedText.append(NSAttributedString(string: " \(text)"))
            label.attributedText = attributedText

            self.paragraphsContainerStackView.addArrangedSubview(label)
        }
    }
}
