import UIKit
import RxCocoa

final class RegistrationView: UIView {

    var backButtonTapEvent: ControlEvent<Void> {
        bannerView.leftButtonTapEvent
    }

    var tapAnywhereEvent: ControlEvent<Void> {
        let tapObservable = tapGestureRecognizer.rx.event
            .map { _ in return () }
        return ControlEvent<Void>(events: tapObservable)
    }

    var requestInProgressBinder: Binder<Bool> {
        return Binder<Bool>(self) { view, inProgress in
            view.progressView.isHidden = !inProgress
            view.progressView.set(animating: inProgress)
            view.bannerView.buttonsVisibleBinder.onNext(!inProgress)
        }
    }

    private let bannerView = BannerView(leftButtonImage: Images.backArrow, rightButtonImage: nil)

    private let contentContainerView = UIView()

    private let progressView = ProgressView()

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
        sendSubviewToBack(contentContainerView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func remove(contentView: UIView) {
        contentView.removeFromSuperview()
    }

    private func addSubviews() {
        addSubviews([bannerView, contentContainerView, progressView])
    }

    private func setupConstraints() {
        bannerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.110 * UIScreen.height)

        }

        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(bannerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        progressView.snp.makeConstraints {
            $0.edges.equalTo(contentContainerView)
        }
    }
}
