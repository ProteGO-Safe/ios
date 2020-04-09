import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SendHistoryProgressView: UIView {

    private let bannerView = BannerView(leftButtonImage: nil, rightButtonImage: nil)

    private let progressView = ProgressView()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        self.addSubviews()
        self.createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimation() {
        progressView.set(animating: true)
    }

    private func addSubviews() {
        self.addSubviews([self.bannerView, self.progressView])
    }

    private func createConstraints() {
        bannerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.110 * UIScreen.height)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(bannerView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
}
