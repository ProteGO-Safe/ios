import Swinject
import Valet

final class RegistrationAssembly: Assembly {

    func assemble(container: Container) {
        registerRegistrationViewController(container)
        registerSendCodeViewController(container)
        registerVerifyCodeViewController(container)
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
                sendCodeViewController: resolver.resolve(SendCodeViewController.self),
                verifyCodeViewController: resolver.resolve(VerifyCodeViewController.self))
        }
    }

    private func registerSendCodeViewController(_ container: Container) {

        container.register(SendCodeModelType.self) { resolver in
            return SendCodeModel(
                gcpClient: resolver.resolve(GcpClientType.self),
                valet: resolver.resolve(Valet.self))
        }

        container.register(SendCodeViewModelType.self) { resolver in
            return SendCodeViewModel(model: resolver.resolve(SendCodeModelType.self))
        }

        container.register(SendCodeViewController.self) { resolver in
            return SendCodeViewController(viewModel: resolver.resolve(SendCodeViewModelType.self))
        }
    }

    private func registerVerifyCodeViewController(_ container: Container) {

        container.register(VerifyCodeModelType.self) { resolver in
            return VerifyCodeModel(
                gcpClient: resolver.resolve(GcpClientType.self),
                valet: resolver.resolve(Valet.self))
        }

        container.register(VerifyCodeViewModelType.self) { resolver in
            return VerifyCodeViewModel(model: resolver.resolve(VerifyCodeModelType.self))
        }

        container.register(VerifyCodeViewController.self) { resolver in
            return VerifyCodeViewController(viewModel: resolver.resolve(VerifyCodeViewModelType.self))
        }
    }
}
