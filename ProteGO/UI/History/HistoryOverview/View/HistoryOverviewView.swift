import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class HistoryOverviewView: UIView {

    var closeButtonTapped: ControlEvent<Void> {
        return bannerView.rightButtonTapEvent
    }

    var sendHistoryButtonTapped: ControlEvent<Void> {
        return sendHistoryButton.rx.tap
    }

    var contactUsEmailButtonTapped: ControlEvent<Void> {
        return contactUsEmailButton.rx.tap
    }

    var termsOfUseButtonTapped: ControlEvent<Void> {
        return termsOfUseButton.rx.tap
    }

    private let bannerView = BannerView(leftButtonImage: nil, rightButtonImage: Images.closeIcon)

    private let yourIdLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.poppinsBold(24).font
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let sendHistoryButton: UIButton = {
        let button = UIButton.rectButton(text: L10n.dashboardInfoSendDataBtn)
        button.setBackgroundColor(.white, forState: .normal)
        button.setBackgroundColor(Colors.darkSeaGreen, forState: .highlighted)
        button.setTitleColor(Colors.bluishGreen, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        return button
    }()

    private let recentHistoryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.poppinsSemiBold(18).font
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let contactUsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.configure(fontStyle: .bodySmall)
        label.text = L10n.dashboardInfoContactUsDescription
        label.textAlignment = .center
        return label
    }()

    private let contactUsEmailButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = Fonts.poppinsSemiBold(14).font
        let text = NSAttributedString(string: L10n.dashboardInfoContactUsEmail,
                                      attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                   NSAttributedString.Key.foregroundColor: UIColor.white])
        button.setAttributedTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()

    private let termsOfUseButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = Fonts.poppinsSemiBold(14).font
        let text = NSAttributedString(string: L10n.dashboardInfoTermsOfUseBtn,
                                      attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                   NSAttributedString.Key.foregroundColor: UIColor.white])
        button.setAttributedTitle(text, for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()

    private let versionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.configure(fontStyle: .bodySmall)
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            let text = "\(appName) \(L10n.dashboardInfoVersion) \(appVersion)"
            label.text = text
        }
        label.textAlignment = .center
        return label
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = Colors.bluishGreen
        self.addSubviews()
        self.createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.addSubviews([self.bannerView,
                          yourIdLabel,
                          sendHistoryButton,
                          recentHistoryLabel,
                          contactUsLabel,
                          contactUsEmailButton,
                          termsOfUseButton,
                          versionLabel])
    }

    private func createConstraints() {
        bannerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.110 * UIScreen.height)
        }

        yourIdLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.bannerView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        sendHistoryButton.snp.makeConstraints {
            $0.top.equalTo(self.yourIdLabel.snp.bottom).offset(23)
            $0.height.equalTo(48)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        recentHistoryLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.contactUsLabel.snp.top).offset(-34)
        }

        contactUsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.contactUsEmailButton.snp.top)
        }

        contactUsEmailButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.termsOfUseButton.snp.top).offset(-17)
        }

        termsOfUseButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.versionLabel.snp.top).offset(-21)
        }

        versionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-43)
        }
    }

    func update(phoneId: String) {
        self.yourIdLabel.text = "\(L10n.dashboardInfoYourId)\n\(phoneId)"
    }

    func update(historyLastDate: String, lastSeenDevicesCount: String) {
        self.recentHistoryLabel.text = L10n.dashboardInfoHistoryOverview(historyLastDate, lastSeenDevicesCount)
    }
}
