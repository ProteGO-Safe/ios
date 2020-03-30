import Swinject
import Valet

//swiftlint:disable force_unwrapping
final class RegistrationAssembly: Assembly {

    func assemble(container: Container) {
        registerRegistrationViewController(container)
        registerSendCodeViewController(container)
        registerVerifyCodeViewController(container)
    }

    private func registerRegistrationViewController(_ container: Container) {

        container.register(RegistrationViewController.self) { resolver in
            return RegistrationViewController(
                sendCodeViewController: resolver.resolve(SendCodeViewController.self),
                verifyCodeViewController: resolver.resolve(VerifyCodeViewController.self))
        }
    }

    private func registerSendCodeViewController(_ container: Container) {

        container.register(SendCodeModelType.self) { resolver in
            return SendCodeModel(
                gcpClient: resolver.resolve(GcpClientType.self),
                valet: Valet.valet(with: Identifier(nonEmpty: "Registration")!, accessibility: .afterFirstUnlock))
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
                valet: Valet.valet(with: Identifier(nonEmpty: "Registration")!, accessibility: .afterFirstUnlock))
        }

        container.register(VerifyCodeViewModelType.self) { resolver in
            return VerifyCodeViewModel(model: resolver.resolve(VerifyCodeModelType.self))
        }

        container.register(VerifyCodeViewController.self) { resolver in
            return VerifyCodeViewController(viewModel: resolver.resolve(VerifyCodeViewModelType.self))
        }
    }
}
