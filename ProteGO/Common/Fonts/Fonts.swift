import UIKit

//swiftlint:disable force_unwrapping
public enum Fonts {

    case poppinsBold(CGFloat)
    case poppinsRegular(CGFloat)
    case poppinsMedium(CGFloat)

    public var font: UIFont {
        switch self {
        case .poppinsBold(let size):
            return UIFont(name: "Poppins-Bold", size: size)!
        case .poppinsRegular(let size):
            return UIFont(name: "Poppins-Regular", size: size)!
        case .poppinsMedium(let size):
            return UIFont(name: "Poppins-Medium", size: size)!
        }
    }
}
