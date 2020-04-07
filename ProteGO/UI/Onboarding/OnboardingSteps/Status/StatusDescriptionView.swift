import UIKit

final class StatusDesciptionView: UIView {

    private lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 4
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = text
        label.font = Fonts.poppinsSemiBold(16).font
        label.textColor = UIColor(asset: Assets.lightBlack)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    private let color: UIColor

    private let text: String

    init(color: UIColor, text: String) {
        self.color = color
        self.text = text
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addSubviews() {
        addSubviews([colorView, descriptionLabel])
    }

    func setupConstraints() {
        colorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.width.equalTo(18)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(colorView)
            $0.leading.equalTo(colorView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
