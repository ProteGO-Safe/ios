import Foundation

protocol DashboardViewModelType: class {
    func bind(view: DashboardView)

    func updateCurrentDangerStatus()
}
