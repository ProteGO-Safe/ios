import Swinject
import CoreLocation

final class RootViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        registerRootViewController(container)
    }

    private func registerRootViewController(_ container: Container) {
        container.register(RootModelType.self) { resolver in
            return RootModel(
                locationTrackingManager: resolver.resolve(LocationTrackingManagerType.self),
                permissionsManager: resolver.resolve(PermissionsManagerType.self)
            )
        }

        container.register(RootViewModelType.self) { resolver in
            return RootViewModel(model: resolver.resolve(RootModelType.self))
        }

        container.register(RootViewController.self) { resolver in
            return RootViewController(viewModel: resolver.resolve(RootViewModelType.self))
        }
    }
}
