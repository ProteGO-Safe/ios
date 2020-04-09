import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DashboardView: UIView {

    var greenStatusTapMoreEvent: ControlEvent<Void> {
        greenStatusCardView.tapMoreEvent
    }

    var yellowStatusTapMoreEvent: ControlEvent<Void> {
        yellowStatusCardView.tapMoreEvent
    }

    var redStatusContactButtonTappedEvent: ControlEvent<Void> {
        redStatusCardView.contactButtonTapEvent
    }

    var greenGeneralRecommendationsTapMoreEvent: ControlEvent<Void> {
        greenGeneralRecommendationsCard.tapMoreEvent
    }

    var yellowGeneralRecommendationsTapMoreEvent: ControlEvent<Void> {
        yellowGeneralRecommendationsCard.tapMoreEvent
    }

    var redGeneralRecommendationsTapMoreEvent: ControlEvent<Void> {
        redGeneralRecommendationsCard.tapMoreEvent
    }

    var hamburgerButtonTapEvent: ControlEvent<Void> {
        bannerView.rightButtonTapEvent
    }

    private let containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        return view
    }()

    private let greenStatusCardView = GreenStatusCardView()

    private let yellowStatusCardView = YellowStatusCardView()

    private let redStatusCardView = RedStatusCardView()

    private let greenGeneralRecommendationsCard: GeneralRecommendationsCard = {
        let config = GeneralRecommendationsCardConfig(
            title: L10n.dashboardGreenRecommendTitle,
            paragraphs: [L10n.dashboardGreenRecommend1,
                         L10n.dashboardGreenRecommend2,
                         L10n.dashboardGreenRecommend3],
            footerTextFunction: L10n.dashboardGreenRecommendMoreInfoBtn,
            footerHereText: L10n.dashboardGreenRecommendMoreInfoBtnHere)
        return GeneralRecommendationsCard(config: config)
    }()

    private let yellowGeneralRecommendationsCard: GeneralRecommendationsCard = {
        let config = GeneralRecommendationsCardConfig(
            title: L10n.dashboardYellowRecommendTitle,
            paragraphs: [L10n.dashboardYellowRecommend1,
                         L10n.dashboardYellowRecommend2,
                         L10n.dashboardYellowRecommend3],
            footerTextFunction: L10n.dashboardYellowRecommendMoreInfoBtn,
            footerHereText: L10n.dashboardYellowRecommendMoreInfoBtnHere)
        return GeneralRecommendationsCard(config: config)
    }()

    private let redGeneralRecommendationsCard: GeneralRecommendationsCard = {
        let config = GeneralRecommendationsCardConfig(
            title: L10n.dashboardRedRecommendTitle,
            paragraphs: [L10n.dashboardRedRecommend1,
                         L10n.dashboardRedRecommend2,
                         L10n.dashboardRedRecommend3],
            footerTextFunction: L10n.dashboardRedRecommendMoreInfoBtn,
            footerHereText: L10n.dashboardRedRecommendMoreInfoBtnHere)
        return GeneralRecommendationsCard(config: config)
    }()

    private let bannerView = BannerView(leftButtonImage: nil, rightButtonImage: Images.hamburgerIcon)

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubviews([bannerView, containerScrollView])
        containerScrollView.addSubview(containerStackView)
    }

    private func setupConstraints() {
        bannerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.110 * UIScreen.height)
        }

        containerScrollView.snp.makeConstraints {
            $0.top.equalTo(bannerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaInsets.bottom)
        }

        containerStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalToSuperview().offset(-50)
        }
    }

    func update(withStatus status: DangerStatus) {
        for view in containerStackView.arrangedSubviews {
            containerStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        switch status {
        case .green:
            containerStackView.addArrangedSubviews([greenStatusCardView, greenGeneralRecommendationsCard])
        case .yellow:
            containerStackView.addArrangedSubviews([yellowStatusCardView, yellowGeneralRecommendationsCard])
        case .red:
            containerStackView.addArrangedSubviews([redStatusCardView, redGeneralRecommendationsCard])
        }
    }
}
