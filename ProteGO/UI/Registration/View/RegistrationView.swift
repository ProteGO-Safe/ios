import UIKit
import RxCocoa

final class RegistrationView: UIView {

    var backButtonTapEvent: ControlEvent<Void> {
        bannerView.backButtonTapEvent
    }

    var tapAnywhereEvent: ControlEvent<Void> {
        let tapObservable = tapGestureRecognizer.rx.event
            .map { _ in return () }
        return ControlEvent<Void>(events: tapObservable)
    }

    private let bannerView = BannerView(withBackButton: true)

    private let contentContainerView = UIView()

    private let tapGestureRecognizer = UITapGestureRecognizer()

    init() {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        addGestureRecognizer(tapGestureRecognizer)
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
