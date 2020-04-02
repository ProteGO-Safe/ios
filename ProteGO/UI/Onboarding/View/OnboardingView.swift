import UIKit
import SnapKit
import RxCocoa

final class OnboardingView: UIView {

    var backButtonTapEvent: ControlEvent<Void> {
        return navigationButtonsView.backButtonTapEvent
    }

    var nextButtonTapEvent: ControlEvent<Void> {
        return navigationButtonsView.nextButtonTapEvent
    }

    var backButtonVisibleBinder: Binder<Bool> {
        return navigationButtonsView.backButtonVisibleBinder
    }

    private let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let stepScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0.300 * UIScreen.height, left: .zero, bottom: .zero, right: .zero)
        return scrollView
    }()

    private let navigationButtonsView = NavigationButtonsView()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(contentView: UIView) {
        stepScrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(self)
        }
        stepScrollView.setContentOffset(CGPoint(x: .zero, y: -0.300 * UIScreen.height), animated: false)
    }

    func removeContentView() {
        for subview in stepScrollView.subviews {
            subview.removeFromSuperview()
        }
    }

    func set(bannerImage: UIImage) {
        bannerImageView.image = bannerImage
    }

    private func addSubviews() {
        addSubviews([bannerImageView, stepScrollView, navigationButtonsView])
    }

    private func setupConstraints() {
        bannerImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.300 * UIScreen.height)
        }

        stepScrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(navigationButtonsView.snp.top)
        }

        navigationButtonsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaInsets.bottom)
        }
    }
}
