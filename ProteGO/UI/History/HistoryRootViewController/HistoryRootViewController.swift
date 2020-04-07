import UIKit

protocol HistoryRootViewControllerDelegate: class {
    func sendHistoryFinished(result: Result<Void, Error>)
}

final class HistoryRootViewController: UINavigationController {

    weak var historyRootViewControllerDelegate: HistoryRootViewControllerDelegate?

    init(historyOverviewViewController: HistoryOverviewViewController) {
        super.init(rootViewController: historyOverviewViewController)
        historyOverviewViewController.delegate = self
        self.navigationBar.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HistoryRootViewController: HistoryOverviewViewControllerDelegate {
    func sendHistoryFinished(result: Result<Void, Error>) {
        self.dismiss(animated: false) { [weak self] in
            self?.historyRootViewControllerDelegate?.sendHistoryFinished(result: result)
        }
    }
}
