import UIKit

extension UILabel {

    static func with(text: String, fontStyle: FontStyle, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> UILabel {
        let label = UILabel()

        label.text = text
        label.font = fontStyle.font
        label.textColor = fontStyle.color

        label.lineBreakMode = lineBreakMode

        label.numberOfLines = 0

        return label
    }
}
