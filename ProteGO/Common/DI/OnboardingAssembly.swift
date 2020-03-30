import Swinject

final class OnboardingAssembly: Assembly {

    func assemble(container: Container) {
        registerOnboardingViewController(container)
    }

    private func registerOnboardingViewController(_ container: Container) {
        container.register(OnboardingViewController.self) { _ in
            return OnboardingViewController()
        }
    }
}
