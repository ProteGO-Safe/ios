import Swinject

final class DashboardAssembly: Assembly {

    func assemble(container: Container) {
        registerDashboardViewController(container)
        registerDashboardViewModel(container)
        registerDashboardModel(container)
    }

    private func registerDashboardViewController(_ container: Container) {
        container.register(DashboardViewController.self) { resolver in
            let historyOverviewBuilder: HistoryOverviewViewControllerBuilder = {
                return resolver.resolve(HistoryOverviewViewController.self)
            }
            let viewModel: DashboardViewModelType = resolver.resolve(DashboardViewModelType.self)
            return DashboardViewController(viewModel: viewModel, historyOverViewBuilder: historyOverviewBuilder)
        }
    }

    private func registerDashboardViewModel(_ container: Container) {
        container.register(DashboardViewModelType.self) { resolver in
            return DashboardViewModel(model: resolver.resolve(DashboardModelType.self))
        }
    }

    private func registerDashboardModel(_ container: Container) {
        container.register(DashboardModelType.self) { resolver in
            return DashboardModel(dangerStatusManager: resolver.resolve(DangerStatusManagerType.self))
        }
    }
}
