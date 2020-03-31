import UIKit

enum FontStyle {

    case headline
    case subtitle
    case body
    case captions

    var font: UIFont {
        switch self {
        case .headline:
            return Fonts.poppinsBold(48).font
        case .subtitle:
            return Fonts.poppinsBold(24).font
        case .body:
            return Fonts.poppinsRegular(16).font
        case .captions:
            return Fonts.poppinsRegular(12).font
        }
    }

    var color: UIColor {
        switch self {
        case .headline, .subtitle:
            return Colors.lightBlack
        case .body, .captions:
            return Colors.greyishBrown
        }
    }
}
