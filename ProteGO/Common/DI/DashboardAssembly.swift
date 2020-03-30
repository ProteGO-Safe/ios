import Swinject

final class DashboardAssembly: Assembly {

    func assemble(container: Container) {
        registerDashboardViewController(container)
    }

    private func registerDashboardViewController(_ container: Container) {
        container.register(DashboardViewController.self) { _ in
            return DashboardViewController()
        }
    }
}
