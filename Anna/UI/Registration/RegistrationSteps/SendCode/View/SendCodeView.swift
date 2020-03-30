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

    private let titleLabel = UILabel.with(text: "Dołącz do aplikacji", fontStyle: .headline)

    private let descriptionLabel = UILabel.with(text: """
        Żeby potwierdzić Twoje konto podaj swój numer telefonu. Prześlemy Ci kod weryfikujący.

        Nie będziemy łączyć Twoich danych z numerem telefonu.
        """, fontStyle: .body)

    private let prefixTextField: UITextField = {
        let textField = UITextField.with(text: "+48", centered: true)
        textField.textAlignment = .center
        textField.isUserInteractionEnabled = false
        return textField
    }()

    private let phoneNumberTextField: UITextField = {
        let textField = UITextField.with(placeholder: "XXX-XXX-XXX")
        textField.keyboardType = .numberPad
        return textField
    }()

    private let sendCodeButton = UIButton.rectButton(text: "Prześlij kod")

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
