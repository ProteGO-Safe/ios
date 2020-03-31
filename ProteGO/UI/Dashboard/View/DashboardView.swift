import UIKit
import SnapKit

final class DashboardView: UIView {

    let label = UILabel.with(text: "Dashboard", fontStyle: .headline)

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
        addSubviews([label])
    }

    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
