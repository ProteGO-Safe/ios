import UIKit

extension UILabel {

    static func with(text: String, fontStyle: FontStyle, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> UILabel {
        let label = UILabel()
        label.configure(text: text, fontStyle: fontStyle, lineBreakMode: lineBreakMode)
        return label
    }

    func configure(text: String, fontStyle: FontStyle, lineBreakMode: NSLineBreakMode = .byWordWrapping) {
        self.text = text
        self.configure(fontStyle: fontStyle, lineBreakMode: lineBreakMode)
    }

    func configure(fontStyle: FontStyle, lineBreakMode: NSLineBreakMode = .byWordWrapping) {
        self.font = fontStyle.font
        self.textColor = fontStyle.color

        self.lineBreakMode = lineBreakMode

        self.numberOfLines = 0
    }
}
