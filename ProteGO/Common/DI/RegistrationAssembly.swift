import Swinject

final class RegistrationAssembly: Assembly {

    func assemble(container: Container) {
        registerRegistrationViewController(container)
    }

    private func registerRegistrationViewController(_ container: Container) {
        container.register(RegistrationViewController.self) { _ in
            return RegistrationViewController()
        }
    }
}
