import UIKit

class OnboardingStepView: UIView {

    private lazy var titleLabel = UILabel.with(text: titleText, fontStyle: titleStyle)

    private lazy var descriptionLabel = UILabel.with(text: descriptionText, fontStyle: .body)

    private let titleText: String

    private let titleStyle: FontStyle

    private let descriptionText: String

    private let bottomView: UIView?

    init(titleText: String,
         titleStyle: FontStyle,
         descriptionText: String,
         bottomView: UIView? = nil) {

        self.titleText = titleText
        self.titleStyle = titleStyle
        self.descriptionText = descriptionText
        self.bottomView = bottomView

        super.init(frame: .zero)

        backgroundColor = .white
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubviews([titleLabel, descriptionLabel])
        if let bottomView = bottomView {
            addSubview(bottomView)
        }
    }

    private func setupConstraints() {

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0.029 * UIScreen.height)
            $0.leading.equalToSuperview().offset(0.064 * UIScreen.width)
            $0.trailing.equalToSuperview().offset(-0.064 * UIScreen.width)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(0.020 * UIScreen.height)
            $0.leading.trailing.equalTo(titleLabel)
            if bottomView == nil {
                $0.bottom.equalToSuperview()
            }
        }

        bottomView?.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(0.018 * UIScreen.height)
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.equalToSuperview()
        }
    }
}
