import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SendHistoryConfirmView: UIView {

    var backButtonTapped: ControlEvent<Void> {
        return bannerView.leftButtonTapEvent
    }

    var sendHistoryButtonTapped: ControlEvent<Void> {
        return sendHistoryButton.rx.tap
    }

    var confirmationCode: String? {
        return self.codeTextField.text
    }

    private let bannerView = BannerView(leftButtonImage: Images.backArrow, rightButtonImage: nil)

    private let contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private let containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let sendHistoryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.configure(text: L10n.sendDataTitle, fontStyle: .subtitle)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private let sendHistoryDescription: UILabel = {
        let label = UILabel(frame: .zero)
        label.configure(text: L10n.sendDataDescription, fontStyle: .body)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let yourIdLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.poppinsBold(18).font
        label.textColor = Colors.lightBlack
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let confirmationCodeDescriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.poppinsMedium(14).font
        label.textColor = Colors.greyishBrown
        label.text = L10n.sendDataConfirmCodeDescription
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let codeTextField: UITextField = {
        let textField = UITextField.with(placeholder: L10n.sendDataConfirmCodePlaceholder)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .send
        return textField
    }()

    private let sendHistoryButton: UIButton = {
        let button = UIButton.rectButton(text: L10n.sendDataSendButton, textColor: .white)
        button.isEnabled = false
        button.setBackgroundColor(Colors.darkSeaGreen, forState: .highlighted)
        button.setBackgroundColor(Colors.pinkishGrey, forState: .disabled)
        return button
    }()

    private let tapGestureRecognizer = UITapGestureRecognizer()

    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        self.codeTextField.delegate = self
        self.addSubviews()
        self.createConstraints()
        self.setupDismissKeyboard()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.addSubviews([self.bannerView,
                          self.containerScrollView])

        self.containerScrollView.addSubview(self.contentView)

        self.contentView.addSubviews([self.sendHistoryLabel,
                                      self.sendHistoryDescription,
                                      self.yourIdLabel,
                                      self.confirmationCodeDescriptionLabel,
                                      self.codeTextField,
                                      self.sendHistoryButton])
    }

    private func createConstraints() {
        bannerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.110 * UIScreen.height)
        }

        containerScrollView.snp.makeConstraints {
            $0.top.equalTo(self.bannerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.top.leading.width.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }

        sendHistoryLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        sendHistoryDescription.snp.makeConstraints {
            $0.top.equalTo(self.sendHistoryLabel.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        yourIdLabel.snp.makeConstraints {
            $0.top.equalTo(self.sendHistoryDescription.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        confirmationCodeDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.yourIdLabel.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        codeTextField.snp.makeConstraints {
            $0.top.equalTo(self.confirmationCodeDescriptionLabel.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }

        sendHistoryButton.snp.makeConstraints {
            $0.top.equalTo(self.codeTextField.snp.bottom).offset(22)
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-22)
        }
    }

    func update(phoneId: String) {
        self.yourIdLabel.text = "\(L10n.sendDataYourId)\n\(phoneId)"
    }

    func update(keyboardHeight: CGFloat) {
        UIView.animate(withDuration: 0) { [weak self] in
            guard let self = self else {
                logger.error("Instance deallocated file: \(#file), line: \(#line)")
                return
            }

            if keyboardHeight > 0 {
                let bottomOffset = self.containerScrollView.contentSize.height -
                    self.containerScrollView.bounds.size.height + self.containerScrollView.contentInset.bottom
                self.containerScrollView.contentOffset = CGPoint(x: .zero, y: bottomOffset + keyboardHeight)
                self.containerScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            } else {
                self.containerScrollView.contentOffset = .zero
                self.containerScrollView.contentInset = .zero
            }
        }
    }

    private func setupDismissKeyboard() {
        self.contentView.addGestureRecognizer(tapGestureRecognizer)
        self.tapGestureRecognizer.rx.event
            .map { _ in return () }
            .subscribe(onNext: { [weak self] _ in
                self?.codeTextField.resignFirstResponder()
            }).disposed(by: self.disposeBag)
    }
}

extension SendHistoryConfirmView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            self.sendHistoryButton.isEnabled = false
            return true
        }

        self.sendHistoryButton.isEnabled = !(text as NSString).replacingCharacters(in: range, with: string).isEmpty
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            self.sendHistoryButton.sendActions(for: .touchUpInside)
        }
        return false
    }
}
