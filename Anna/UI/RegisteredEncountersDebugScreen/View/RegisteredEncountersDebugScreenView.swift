import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class RegisteredEncountersDebugScreenView: UIView {

    var backButtonTapped: ControlEvent<Void> {
        return backButton.rx.tap
    }

    private let backButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Wróć", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    private let registeredEncountersTextView: UITextView = {
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

    public func addEncounterData(deviceId: String, signalStrength: Int?, date: Date) {
        var signalStrengthText = "n/a"

        if let signalStrength = signalStrength {
            signalStrengthText = "\(signalStrength)"
        }

        let newEncounterDescription = "Device: \(deviceId), RSSI: \(signalStrengthText), Date: \(date) \n"
        self.registeredEncountersTextView.text.append(newEncounterDescription)
    }

    private func addSubviews() {
        self.addSubview(self.backButton)
        self.addSubview(self.registeredEncountersTextView)
    }

    private func createConstraints() {
        self.registeredEncountersTextView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.backButton.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.registeredEncountersTextView.snp.top)
            $0.height.equalTo(30)
        }
    }
}
