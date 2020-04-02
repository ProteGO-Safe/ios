import Swinject

final class HistoryOverviewAssembly: Assembly {

    func assemble(container: Container) {
        registerHistoryOverviewViewController(container)
        registerHistoryOverviewViewModel(container)
        registerHistoryOverviewModel(container)
    }

    private func registerHistoryOverviewViewController(_ container: Container) {
        container.register(HistoryOverviewViewController.self) { resolver in
            let viewModel: HistoryOverviewViewModelType = resolver.resolve(HistoryOverviewViewModelType.self)
            return HistoryOverviewViewController(viewModel: viewModel)
        }
    }

    private func registerHistoryOverviewViewModel(_ container: Container) {
        container.register(HistoryOverviewViewModelType.self) { resolver in
            return HistoryOverviewViewModel(model: resolver.resolve(HistoryOverviewModelType.self))
        }
    }

    private func registerHistoryOverviewModel(_ container: Container) {
        container.register(HistoryOverviewModelType.self) { resolver in
            return HistoryOverviewModel(encountersManasger: resolver.resolve(EncountersManagerType.self))
        }
    }
}
