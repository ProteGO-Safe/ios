import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SendHistoryConfirmView: UIView {

    var backButtonTapped: ControlEvent<Void> {
        return bannerView.leftButtonTapEvent
    }

    var sendHistoryButtonTapped: ControlEvent<Void> {
        return sendHistoryButton.rx.tap
    }

    private let bannerView = BannerView(leftButtonImage: Images.backArrow, rightButtonImage: nil)

    private let sendHistoryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.configure(text: L10n.sendDataTitle, fontStyle: .subtitle)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private let sendHistoryDescription: UILabel = {
        let label = UILabel(frame: .zero)
        label.configure(text: L10n.sendDataDescription, fontStyle: .body)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

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
        let button = UIButton(frame: .zero)
        button.setBackgroundColor(Colors.bluishGreen, forState: .normal)
        button.setBackgroundColor(Colors.darkSeaGreen, forState: .highlighted)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitle(L10n.sendDataSendButton, for: .normal)
        button.titleLabel?.font = Fonts.poppinsMedium(16).font
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        return button
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
        self.addSubviews([self.bannerView,
                          sendHistoryLabel,
                          sendHistoryDescription,
                          yourIdLabel,
                          sendHistoryButton])
    }

    private func createConstraints() {
        bannerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.110 * UIScreen.height)
        }

        sendHistoryLabel.snp.makeConstraints {
            $0.top.equalTo(self.bannerView.snp.bottom).offset(23)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        sendHistoryDescription.snp.makeConstraints {
            $0.top.equalTo(self.sendHistoryLabel.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        yourIdLabel.snp.makeConstraints {
            $0.top.equalTo(self.sendHistoryDescription.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        sendHistoryButton.snp.makeConstraints {
            $0.top.equalTo(self.yourIdLabel.snp.bottom).offset(22)
            $0.height.equalTo(48)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }

    func update(phoneId: String) {
        self.yourIdLabel.text = "\(L10n.sendDataYourId)\n\(phoneId)"
    }
}
