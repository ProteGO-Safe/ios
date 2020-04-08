import UIKit

extension UITextField {

    static func with(placeholder: String = "",
                     text: String? = nil,
                     centered: Bool = false) -> UITextField {

        let textField = UITextField()

        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.poppinsMedium(16).font,
            .foregroundColor: UIColor(asset: Assets.greyish)!] // swiftlint:disable:this force_unwrapping
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.poppinsMedium(16).font,
            .foregroundColor: UIColor(asset: Assets.bluishGreen)!] // swiftlint:disable:this force_unwrapping
        if let text = text {
            textField.attributedText = NSAttributedString(string: text, attributes: textAttributes)
        } else {
            textField.defaultTextAttributes = textAttributes
        }

        textField.layer.cornerRadius = 4
        textField.layer.borderColor = UIColor(asset: Assets.greyish).cgColor
        textField.layer.borderWidth = 1

        if centered {
            textField.textAlignment = .center
        } else {
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
            textField.leftView = paddingView
            textField.leftViewMode = .always
        }

        return textField
    }
}
