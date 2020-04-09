import UIKit
import RxCocoa

final class BannerView: UIView {

    var buttonsVisibleBinder: Binder<Bool> {
        return Binder<Bool>(self) { view, visible in
            view.leftButton.isHidden = !visible
            view.rightButton.isHidden = !visible
        }
    }

    var leftButtonTapEvent: ControlEvent<Void> {
        return leftButton.rx.tap
    }

    var rightButtonTapEvent: ControlEvent<Void> {
        return rightButton.rx.tap
    }

    private let leftButton: UIButton = {
        let button = UIButton()
        button.setImage(Images.backArrow, for: .normal)
        return button
    }()

    private let logoView: UIImageView = {
        let image = UIImageView(image: Images.logoSmall)
        image.contentMode = .scaleAspectFit
        return image
    }()

    private let rightButton: UIButton = {
        let button = UIButton()
        return button
    }()

    init(leftButtonImage: UIImage?, rightButtonImage: UIImage?) {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        backgroundColor = Colors.bluishGreen
        self.setupLeftButton(image: leftButtonImage)
        self.setupRightButton(image: rightButtonImage)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubviews([leftButton, logoView, rightButton])
    }

    private func setupConstraints() {
        logoView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(29)
        }

        leftButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalTo(logoView)
        }

        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalTo(logoView)
        }
    }

    private func setupLeftButton(image: UIImage?) {
        if let image = image {
            leftButton.isHidden = false
            leftButton.setImage(image, for: .normal)
        } else {
            leftButton.isHidden = true
        }
    }

    private func setupRightButton(image: UIImage?) {
        if let image = image {
            rightButton.isHidden = false
            rightButton.setImage(image, for: .normal)
        } else {
            rightButton.isHidden = true
        }
    }
}
