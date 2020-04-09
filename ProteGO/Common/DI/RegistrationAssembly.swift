import Swinject
import Valet

final class RegistrationAssembly: Assembly {

    func assemble(container: Container) {
        registerRegistrationManager(container)
        registerRegistrationViewController(container)
        registerSendCodeViewController(container)
        registerVerifyCodeViewController(container)
        registerKeyboardManager(container)
    }

    private func registerRegistrationManager(_ container: Container) {
        container.register(RegistrationManagerType.self) { resolver in
            return RegistrationManager(keychainProvider: resolver.resolve(KeychainProviderType.self))
        }.inObjectScope(.container)
    }

    private func registerRegistrationViewController(_ container: Container) {

        container.register(RegistrationViewController.self) { resolver in

            container.register(RegistrationModelType.self) { _ in
                return RegistrationModel()
            }

            container.register(RegistrationViewModelType.self) { resolver in
                return RegistrationViewModel(model: resolver.resolve(RegistrationModelType.self))
            }

            return RegistrationViewController(
                viewModel: resolver.resolve(RegistrationViewModelType.self),
                sendCodeViewController: resolver.resolve(RegistrationSendCodeViewController.self),
                verifyCodeViewController: resolver.resolve(RegistrationVerifyCodeViewController.self))
        }
    }

    private func registerSendCodeViewController(_ container: Container) {

        container.register(RegistrationSendCodeModelType.self) { resolver in
            return RegistrationSendCodeModel(
                gcpClient: resolver.resolve(GcpClientType.self),
                keyboardManager: resolver.resolve(KeyboardManagerType.self))
        }

        container.register(RegistrationSendCodeViewModelType.self) { resolver in
            return RegistrationSendCodeViewModel(model: resolver.resolve(RegistrationSendCodeModelType.self))
        }

        container.register(RegistrationSendCodeViewController.self) { resolver in
            return RegistrationSendCodeViewController(viewModel: resolver.resolve(RegistrationSendCodeViewModelType.self))
        }
    }

    private func registerVerifyCodeViewController(_ container: Container) {

        container.register(RegistrationVerifyCodeModelType.self) { resolver in
            return RegistrationVerifyCodeModel(
                gcpClient: resolver.resolve(GcpClientType.self),
                keyboardManager: resolver.resolve(KeyboardManagerType.self))
        }

        container.register(RegistrationVerifyCodeViewModelType.self) { resolver in
            return RegistrationVerifyCodeViewModel(model: resolver.resolve(RegistrationVerifyCodeModelType.self))
        }

        container.register(RegistrationVerifyCodeViewController.self) { resolver in
            return RegistrationVerifyCodeViewController(
                viewModel: resolver.resolve(RegistrationVerifyCodeViewModelType.self))
        }
    }

    private func registerKeyboardManager(_ container: Container) {

        container.register(KeyboardManagerType.self) { _ in
            return KeyboardManager(notificationCenter: NotificationCenter.default)
        }
    }
}
