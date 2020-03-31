import UIKit
import RxCocoa

final class BannerView: UIView {

    var backButtonTapEvent: ControlEvent<Void> {
        return backButton.rx.tap
    }

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(Images.backArrow, for: .normal)
        return button
    }()

    private let logoView: UIImageView = {
        let image = UIImageView(image: Images.logoSmall)
        image.contentMode = .scaleAspectFit
        return image
    }()

    init() {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        backgroundColor = Colors.bluishGreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubviews([backButton, logoView])
    }

    private func setupConstraints() {

        logoView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(29)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalTo(logoView)
        }
    }
}
