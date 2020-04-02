import Swinject

final class OnboardingAssembly: Assembly {

    func assemble(container: Container) {
        registerOnboardingViewController(container)
    }

    private func registerOnboardingViewController(_ container: Container) {
        container.register(OnboardingModelType.self) { _ in
            return OnboardingModel()
        }

        container.register(OnboardingViewModelType.self) { resolver in
            return OnboardingViewModel(model: resolver.resolve(OnboardingModelType.self))
        }

        container.register(OnboardingViewController.self) { resolver in
            return OnboardingViewController(viewModel: resolver.resolve(OnboardingViewModelType.self))
        }
    }
}
