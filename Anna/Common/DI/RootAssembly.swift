import Swinject

final class RootAssembly: Assembly {

    func assemble(container: Container) {
        registerRootModel(container)
        registerRootViewModel(container)
        registerRootViewController(container)
    }

    private func registerRootModel(_ container: Container) {
        container.register(RootModelType.self) { _ in
            return RootModel()
        }
    }

    private func registerRootViewModel(_ container: Container) {
        container.register(RootViewModelType.self) { resolver in
            return RootViewModel(model: resolver.resolve(RootModelType.self))
        }
    }

    private func registerRootViewController(_ container: Container) {
        container.register(RootViewController.self) { resolver in
            return RootViewController(
                viewModel: resolver.resolve(RootViewModelType.self),
                onboardingViewController: resolver.resolve(OnboardingViewController.self),
                registrationViewController: resolver.resolve(RegistrationViewController.self),
                dashboardViewController: resolver.resolve(DashboardViewController.self))
        }
    }
}
