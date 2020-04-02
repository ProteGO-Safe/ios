import UIKit
import SnapKit
import RxCocoa

final class RegistrationVerifyCodeView: UIView {

    var verifyCodeButtonTapEvent: ControlEvent<Void> {
        return verifyCodeButton.rx.tap
    }

    var code: String {
        return codeTextField.text ?? ""
    }

    private let titleLabel = UILabel.with(text: L10n.registrationVerifyTitle, fontStyle: .subtitle)

    private let descriptionLabel = UILabel.with(text: "", fontStyle: .body)

    private let codeTextField: UITextField = {
        let textField = UITextField.with(placeholder: L10n.registrationVerifyCodePlaceholder)
        textField.autocorrectionType = .no
        textField.textContentType = .oneTimeCode
        textField.returnKeyType = .send
        return textField
    }()

    private let verifyCodeButton = UIButton.rectButton(text: L10n.registrationVerifyBtn)

    private let contentContainerView = UIView()

    private var contentBottomConstraint: Constraint?

    init(codeTextFieldDelegate: UITextFieldDelegate) {
        super.init(frame: .zero)
        backgroundColor = .white

        codeTextField.delegate = codeTextFieldDelegate

        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(phoneNumber: String) {
        descriptionLabel.text = L10n.registrationVerifyDescription + "\(phoneNumber)"
    }

    func clearTextField() {
        codeTextField.text = ""
    }

    func dismissKeyboard() {
        codeTextField.resignFirstResponder()
    }

    func update(keyboardHeight: CGFloat) {
        updateContraints(keyboardHeight: keyboardHeight)
        self.setNeedsLayout()
        UIView.animate(withDuration: 0) { [weak self] in
            self?.layoutIfNeeded()
        }
    }

    private func updateContraints(keyboardHeight: CGFloat) {
        if keyboardHeight > 0 {
            contentBottomConstraint?.update(offset: -keyboardHeight).activate()
        } else {
            contentBottomConstraint?.deactivate()
        }
    }

    private func addSubviews() {
        addSubviews([contentContainerView])
        contentContainerView.addSubviews([titleLabel, descriptionLabel, codeTextField, verifyCodeButton])
    }

    private func setupConstraints() {
        contentContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().priority(.low)
            contentBottomConstraint = $0.bottom.lessThanOrEqualToSuperview().constraint
            $0.leading.trailing.equalToSuperview()
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

        codeTextField.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(0.038 * UIScreen.height)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(48)
        }

        verifyCodeButton.snp.makeConstraints {
            $0.top.equalTo(codeTextField.snp.bottom).offset(0.030 * UIScreen.height)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-0.030 * UIScreen.height)
        }
    }
}
