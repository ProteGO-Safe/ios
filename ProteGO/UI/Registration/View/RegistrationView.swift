import UIKit
import RxCocoa

final class RegistrationView: UIView {

    var backButtonTapEvent: ControlEvent<Void> {
        bannerView.backButtonTapEvent
    }

    private let bannerView = BannerView()

    private let contentContainerView = UIView()

    init() {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(contentView: UIView) {
        contentContainerView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func remove(contentView: UIView) {
        contentView.removeFromSuperview()
    }

    private func addSubviews() {
        addSubviews([bannerView, contentContainerView])
    }

    private func setupConstraints() {
        bannerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.099 * UIScreen.height)
        }

        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(bannerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
