import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SendHistoryResultDialogView: UIView {

    var closeButtonTapped: ControlEvent<Void> {
        return closeButton.rx.tap
    }

    var footerLabelTapped: ControlEvent<Void> {
        let tapObservable = tapGestureRecognizer.rx.event
            .map { _ in return () }
        return ControlEvent<Void>(events: tapObservable)
    }

    private let dialogContainer = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.poppinsBold(24).font
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.poppinsMedium(14).font
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let footerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center

        let email = L10n.sendDataAlertFooterEmail
        let text = L10n.sendDataAlertFooter(email)

        if let range = text.range(of: email) {
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

            label.attributedText = attributedText
        }

        label.textColor = .white
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Images.closeIcon, for: .normal)
        return button
    }()

    private let tapGestureRecognizer = UITapGestureRecognizer()

    init(success: Bool) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        self.addSubview(dialogContainer)
        self.dialogContainer.addSubviews([titleLabel, descriptionLabel, footerLabel, closeButton])
        self.createConstraints()
        self.footerLabel.addGestureRecognizer(self.tapGestureRecognizer)
        self.configure(success: success)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createConstraints() {
        self.dialogContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        self.closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
        }

        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(55)
            $0.leading.trailing.equalToSuperview().inset(22)
        }

        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(17)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(22)
        }

        self.footerLabel.snp.makeConstraints {
            $0.top.equalTo(self.descriptionLabel.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview().inset(22)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    private func configure(success: Bool) {
        self.dialogContainer.backgroundColor = success ? Colors.bluishGreen : Colors.macaroniAndCheese
        titleLabel.text = success ? L10n.sendDataAlertSuccessTitle : L10n.sendDataAlertFailureTitle
        descriptionLabel.text = success ? L10n.sendDataAlertSuccessDescription : L10n.sendDataAlertFailureDescription
    }
}
