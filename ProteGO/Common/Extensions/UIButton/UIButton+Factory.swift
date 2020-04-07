import UIKit

extension UIButton {

    static func rectButton(text: String,
                           textColor: UIColor = .white,
                           textFont: UIFont = Fonts.poppinsMedium(16).font,
                           backgroundColor: UIColor = Colors.bluishGreen,
                           borderColor: UIColor? = nil,
                           cornerRadius: CGFloat = 4) -> UIButton {
        let button = UIButton.rectButton(textColor: textColor,
                                         textFont: textFont,
                                         backgroundColor: backgroundColor,
                                         borderColor: borderColor,
                                         cornerRadius: cornerRadius)
        button.setTitle(text, for: .normal)
        return button
    }

    static func rectButton(textColor: UIColor = .white,
                           textFont: UIFont = Fonts.poppinsMedium(16).font,
                           backgroundColor: UIColor = Colors.bluishGreen,
                           borderColor: UIColor? = nil,
                           cornerRadius: CGFloat = 4) -> UIButton {

        let button = UIButton(type: .custom)
        button.titleLabel?.font = textFont
        button.setTitleColor(textColor, for: .normal)
        button.setBackgroundColor(backgroundColor, forState: .normal)

        if let borderColor = borderColor {
            button.layer.borderColor = borderColor.cgColor
            button.layer.borderWidth = 1
        }

        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true

        return button
    }
}
