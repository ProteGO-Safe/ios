import UIKit
import SnapKit

extension ConstraintMaker {

    @discardableResult
    public func widthBasedOnAspectRatio(imageView: UIImageView?) -> ConstraintMakerEditable? {
        guard let imageView = imageView, let image = imageView.image else { return nil }
        return self.width.equalTo(imageView.snp.height).multipliedBy(image.aspectRatio)
    }
}
