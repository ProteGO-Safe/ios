import UIKit
import SnapKit
import RxCocoa

final class RegistrationSendCodeView: UIView {

    var sendCodeButtonTapEvent: ControlEvent<Void> {
        return sendCodeButton.rx.tap
    }

    var registerWithoutPhoneNumberTapEvent: ControlEvent<Void> {
        return registerWithoutPhoneNumberButton.rx.tap
    }

    var phoneNumber: String {
        return (prefixTextField.text ?? "") + (phoneNumberTextField.text ?? "")
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentContainerView = UIView()

    private let titleLabel = UILabel.with(text: L10n.registrationSendTitle, fontStyle: .subtitle)

    private let descriptionLabel: UILabel = {
        let boldText = L10n.registrationSendDescriptionOptional
        let descriptionText = L10n.registrationSendDescription(boldText)
        guard let boldRange = descriptionText.range(of: boldText) else { return UILabel() }
        let boldNsRange = NSRange(boldRange, in: descriptionText)

        let attributedText = NSMutableAttributedString(string: descriptionText)
        let wholeTextRange = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: Fonts.poppinsRegular(16).font,
            range: wholeTextRange
        )
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: Fonts.poppinsSemiBold(16).font,
            range: boldNsRange
        )

        let label = UILabel()
        label.attributedText = attributedText
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = Colors.greyishBrown
        return label
    }()

    private let prefixTextField: UITextField = {
        let textField = UITextField.with(text: Constants.Networking.phoneNumberPrefix, centered: true)
        textField.textAlignment = .center
        textField.isUserInteractionEnabled = false
        return textField
    }()

    private let phoneNumberTextField: UITextField = {
        let textField = UITextField.with(placeholder: L10n.registrationPhonePlaceholder)
        textField.keyboardType = .numberPad
        return textField
    }()

    private let sendCodeButton = UIButton.rectButton(text: L10n.registrationSendCodeBtn)

    private let registerWithoutPhoneNumberButton = UIButton.rectButton(
        text: L10n.registrationWithoutPhoneNumberBtn,
        textColor: Colors.bluishGreen,
        backgroundColor: .white, borderColor: Colors.bluishGreen)

    private var scrollViewBottomConstraint: Constraint?

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func clearTextField() {
        phoneNumberTextField.text = ""
    }

    func dismissKeyboard() {
        phoneNumberTextField.resignFirstResponder()
    }

    func update(keyboardHeight: CGFloat) {
        scrollView.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: keyboardHeight, right: .zero)
        if keyboardHeight > 0 {
            let bottomOffset = scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom
            scrollView.contentOffset = CGPoint(x: .zero, y: bottomOffset)
        } else {
            scrollView.contentOffset = .zero
        }

    }

    private func addSubviews() {
        addSubviews([scrollView])
        scrollView.addSubview(contentContainerView)
        contentContainerView.addSubviews([titleLabel,
                                          descriptionLabel,
                                          prefixTextField,
                                          phoneNumberTextField,
                                          sendCodeButton,
                                          registerWithoutPhoneNumberButton])
    }

    private func setupConstraints() {

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentContainerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(self)

        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0.028 * UIScreen.height)
            $0.leading.equalToSuperview().offset(0.064 * UIScreen.width)
            $0.trailing.equalToSuperview().offset(-0.064 * UIScreen.width)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(0.021 * UIScreen.height)
            $0.leading.trailing.equalTo(titleLabel)
        }

        prefixTextField.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(0.038 * UIScreen.height)
            $0.leading.equalTo(titleLabel)
            $0.width.equalTo(65)
            $0.height.equalTo(48)
        }

        phoneNumberTextField.snp.makeConstraints {
            $0.top.equalTo(prefixTextField)
            $0.leading.equalTo(prefixTextField.snp.trailing).offset(11)
            $0.trailing.equalTo(titleLabel)
            $0.height.equalTo(prefixTextField)
        }

        sendCodeButton.snp.makeConstraints {
            $0.top.equalTo(prefixTextField.snp.bottom).offset(0.030 * UIScreen.height)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(48)
        }

        registerWithoutPhoneNumberButton.snp.makeConstraints {
            $0.top.equalTo(sendCodeButton.snp.bottom).offset(0.025 * UIScreen.height)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-0.030 * UIScreen.height)
        }
    }
}
