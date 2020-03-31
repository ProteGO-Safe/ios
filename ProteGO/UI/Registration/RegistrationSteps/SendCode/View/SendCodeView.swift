import UIKit
import SnapKit
import RxCocoa

final class SendCodeView: UIView {

    var sendCodeButtonTapEvent: ControlEvent<Void> {
        return sendCodeButton.rx.tap
    }

    var phoneNumber: String {
        return (prefixTextField.text ?? "") + (phoneNumberTextField.text ?? "")
    }

    private let titleLabel = UILabel.with(text: L10n.registrationSendTitle, fontStyle: .headline)

    private let descriptionLabel = UILabel.with(text: L10n.registrationSendDescription, fontStyle: .body)

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

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func dismissKeyboard() {
        phoneNumberTextField.resignFirstResponder()
    }

    private func addSubviews() {
        addSubviews([titleLabel, descriptionLabel, prefixTextField, phoneNumberTextField, sendCodeButton])
    }

    private func setupConstraints() {
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
    }
}
