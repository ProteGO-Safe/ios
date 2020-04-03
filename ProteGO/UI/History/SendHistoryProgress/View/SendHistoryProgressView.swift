import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Lottie

final class SendHistoryProgressView: UIView {

    private let bannerView = BannerView(leftButtonImage: nil, rightButtonImage: nil)

    private lazy var progressSpinner: AnimationView = {
        let animationView = AnimationView(name: "progressSpinnerGreen")
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        self.addSubviews()
        self.createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.addSubviews([self.bannerView, self.progressSpinner])
    }

    private func createConstraints() {
        bannerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.110 * UIScreen.height)
        }

        progressSpinner.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(61)
        }
    }
}
