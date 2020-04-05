import Swinject
import Valet

final class HistoryOverviewAssembly: Assembly {

    func assemble(container: Container) {
        registerHistoryRootViewController(container)

        registerHistoryOverviewViewController(container)
        registerHistoryOverviewViewModel(container)
        registerHistoryOverviewModel(container)

        registerSendHistoryConfirmViewController(container)
        registerSendHistoryConfirmViewModel(container)
        registerSendHistoryConfirmModel(container)

        registerSendHistoryProgressViewController(container)
        registerSendHistoryProgressViewModel(container)
        registerSendHistoryProgressModel(container)
    }

    private func registerHistoryRootViewController(_ container: Container) {
        container.register(HistoryRootViewController.self) { resolver in
            let viewController: HistoryOverviewViewController = resolver.resolve(HistoryOverviewViewController.self)
            return HistoryRootViewController(historyOverviewViewController: viewController)
        }
    }

    private func registerHistoryOverviewViewController(_ container: Container) {
        container.register(HistoryOverviewViewController.self) { resolver in
            let builder: SendHistoryConfirmViewControllerBuilder = {
                return resolver.resolve(SendHistoryConfirmViewController.self)
            }
            let viewModel: HistoryOverviewViewModelType = resolver.resolve(HistoryOverviewViewModelType.self)
            return HistoryOverviewViewController(viewModel: viewModel, sendHistoryConfirmViewControllerBuilder: builder)
        }
    }

    private func registerHistoryOverviewViewModel(_ container: Container) {
        container.register(HistoryOverviewViewModelType.self) { resolver in
            return HistoryOverviewViewModel(model: resolver.resolve(HistoryOverviewModelType.self))
        }
    }

    private func registerHistoryOverviewModel(_ container: Container) {
        container.register(HistoryOverviewModelType.self) { resolver in
            let encountersManager: EncountersManagerType = resolver.resolve(EncountersManagerType.self)
            let valet: Valet = resolver.resolve(Valet.self)
            return HistoryOverviewModel(encountersManager: encountersManager, valet: valet)
        }
    }

    private func registerSendHistoryConfirmViewController(_ container: Container) {
        container.register(SendHistoryConfirmViewController.self) { resolver in
            let builder: SendHistoryProgressViewControllerBuilder = {
                return resolver.resolve(SendHistoryProgressViewController.self)
            }
            let viewModel: SendHistoryConfirmViewModelType = resolver.resolve(SendHistoryConfirmViewModelType.self)
            return SendHistoryConfirmViewController(viewModel: viewModel, sendHistoryProgressViewControllerBuilder: builder)
        }
    }

    private func registerSendHistoryConfirmViewModel(_ container: Container) {
        container.register(SendHistoryConfirmViewModelType.self) { resolver in
            return SendHistoryConfirmViewModel(model: resolver.resolve(SendHistoryConfirmModelType.self))
        }
    }

    private func registerSendHistoryConfirmModel(_ container: Container) {
        container.register(SendHistoryConfirmModelType.self) { resolver in
            let valet: Valet = resolver.resolve(Valet.self)
            return SendHistoryConfirmModel(valet: valet)
        }
    }

    private func registerSendHistoryProgressViewController(_ container: Container) {
        container.register(SendHistoryProgressViewController.self) { resolver in
            let viewModel: SendHistoryProgressViewModelType = resolver.resolve(SendHistoryProgressViewModelType.self)
            return SendHistoryProgressViewController(viewModel: viewModel)
        }
    }

    private func registerSendHistoryProgressViewModel(_ container: Container) {
        container.register(SendHistoryProgressViewModelType.self) { resolver in
            return SendHistoryProgressViewModel(model: resolver.resolve(SendHistoryProgressModelType.self))
        }
    }

    private func registerSendHistoryProgressModel(_ container: Container) {
        container.register(SendHistoryProgressModelType.self) { _ in
            return SendHistoryProgressModel()
        }
    }
}
