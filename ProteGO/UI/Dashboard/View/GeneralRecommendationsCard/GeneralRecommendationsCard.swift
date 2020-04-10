import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct GeneralRecommendationsCardConfig {
    let title: String
    let paragraphs: [String]
}

class GeneralRecommendationsCard: UIView {

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

    init(config: GeneralRecommendationsCardConfig) {
        super.init(frame: .zero)
        backgroundColor = .white
        self.layer.borderColor = Colors.greyish.cgColor
        self.layer.borderWidth = 1

        self.addSubviews()
        self.setupConstraints()

        self.setupTitleLabel(text: config.title)
        self.setupParagraphs(paragraphTexts: config.paragraphs)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.addSubview(self.generalContainerStackView)
        self.generalContainerStackView.addArrangedSubviews([
            self.titleLabel,
            self.paragraphsContainerStackView])
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
