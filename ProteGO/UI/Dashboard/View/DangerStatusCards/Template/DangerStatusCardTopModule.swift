import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DangerStatusCardTopModule: UIView {

    private let coloredBoxView = UIView()

    private let titleLabel = UILabel()

    init() {
        super.init(frame: .zero)

        self.addSubviews()
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.addSubviews([coloredBoxView, titleLabel])
    }

    private func setupConstraints() {
        self.coloredBoxView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.top.equalToSuperview().offset(22)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.width.equalTo(18)
        }

        self.titleLabel.snp.makeConstraints {
            $0.leading.equalTo(self.coloredBoxView.snp.trailing).offset(12)
            $0.centerY.equalTo(self.coloredBoxView.snp.centerY)
            $0.trailing.lessThanOrEqualTo(self).offset(-20)
        }
    }

    private func setupColoredBoxViewBuilder(color: UIColor) {
        self.coloredBoxView.backgroundColor = color
        self.coloredBoxView.layer.cornerRadius = 4
    }

    private func setupTitleLabel(text: String) {
        self.titleLabel.configure(text: text, fontStyle: .title)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.numberOfLines = 1
    }

    func configure(config: DangerStatusCardConfig) {
        self.setupColoredBoxViewBuilder(color: config.color)
        self.setupTitleLabel(text: config.titleText)
    }
}
