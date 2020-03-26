import UIKit
import RxSwift
import RxCocoa
import CoreLocation

final class RootViewController: UIViewController, CustomView {

    typealias ViewClass = RootView

    private let viewModel: RootViewModelType

    private let disposeBag = DisposeBag()

    init(viewModel: RootViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ViewClass()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        observeAppDidBecomeActive()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        askForLocationAlwaysPermissionIfNeeded()
    }

    private func observeAppDidBecomeActive() {
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.askForLocationAlwaysPermissionIfNeeded()
            }).disposed(by: disposeBag)
    }

    private func askForLocationAlwaysPermissionIfNeeded() {
        switch viewModel.locationPermission {
        case .notDetermined:
            viewModel.requestLocationPermissionAlways()
        case .denied, .restricted, .authorizedWhenInUse:
            presentLocationPermissionGoToSettingsAlert()
        case .authorizedAlways:
            return
        @unknown default:
            return
        }
    }

    private func presentLocationPermissionGoToSettingsAlert() {
        let appName = Bundle.main.displayName ?? "Aplikacja"
        let alertController = UIAlertController(
            title: "Udostępnij swoje położenie",
            message: "Przejdź do: Ustawienia->\(appName)->Położenie i wybierz Zawsze.",
            preferredStyle: .alert)

        let goToSettingsAction = UIAlertAction(
            title: "Przejdź do Ustawień",
            style: .default,
            handler: { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
        })
        alertController.addAction(goToSettingsAction)

        present(alertController, animated: true)
    }
}
