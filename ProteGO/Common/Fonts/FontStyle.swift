import UIKit

enum FontStyle {

    case headline
    case subtitle
    case title
    case body
    case bodySmall
    case captions

    var font: UIFont {
        switch self {
        case .headline:
            return Fonts.poppinsBold(48).font
        case .subtitle:
            return Fonts.poppinsBold(24).font
        case .body:
            return Fonts.poppinsRegular(16).font
        case .bodySmall:
            return Fonts.poppinsMedium(14).font
        case .captions:
            return Fonts.poppinsRegular(12).font
        case .title:
            return Fonts.poppinsSemiBold(18).font
        }
    }

    var color: UIColor {
        switch self {
        case .headline, .subtitle, .title:
            return Colors.lightBlack
        case .body, .captions:
            return Colors.greyishBrown
        case .bodySmall:
            return .white
        }
    }
}
