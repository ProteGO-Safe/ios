import UIKit
import SnapKit

final class RootView: UIView {

    private let contentContainerView = UIView()

    init() {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
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
        addSubview(contentContainerView)
    }

    private func setupConstraints() {
        contentContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
