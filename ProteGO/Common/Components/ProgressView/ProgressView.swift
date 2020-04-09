import UIKit
import Lottie

final class ProgressView: UIView {

    private lazy var spinnerView: AnimationView = {
        let animationView = AnimationView(name: "progressSpinnerGreen")
        animationView.loopMode = .loop
        return animationView
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(animating: Bool) {
        if animating {
            spinnerView.stop()
            spinnerView.play()
        } else {
            spinnerView.stop()
        }
    }

    private func addSubviews() {
        addSubviews([spinnerView])
    }

    private func setupConstraints() {
        spinnerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(61)
        }
    }
}
