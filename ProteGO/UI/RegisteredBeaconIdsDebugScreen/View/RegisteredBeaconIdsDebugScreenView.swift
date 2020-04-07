import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class RegisteredBeaconIdsDebugScreenView: UIView {

    var backButtonTapped: ControlEvent<Void> {
        return backButton.rx.tap
    }

    private let backButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Wróć", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    private let registeredBeaconsTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.backgroundColor = .white
        textView.textColor = .black
        return textView
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

    public func addBeaconData(beaconData: Data, date: Date, prefix: String = "") {
        let newBeaconDescription = "\(prefix) Beacon: \(beaconData.toHexString()), " +
        "Date: \(DateFormatter.yyyyMMddHH.string(from: date)) \n"
        self.registeredBeaconsTextView.text.append(newBeaconDescription)
    }

    private func addSubviews() {
        self.addSubview(self.backButton)
        self.addSubview(self.registeredBeaconsTextView)
    }

    private func createConstraints() {
        self.registeredBeaconsTextView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.backButton.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.registeredBeaconsTextView.snp.top)
            $0.height.equalTo(30)
        }
    }
}
