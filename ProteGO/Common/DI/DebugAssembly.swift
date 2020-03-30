import Swinject

final class DebugAssembly: Assembly {

    func assemble(container: Container) {
        registerRegisteredEncountersDebugModel(container)
        registerRegisteredEncountersDebugViewModel(container)
        registerRegisteredEncountersDebugViewController(container)
    }

    private func registerRegisteredEncountersDebugModel(_ container: Container) {
        container.register(RegisteredEncountersDebugModelType.self) { resolver in
            let encountersManager: EncountersManagerType = resolver.resolve(EncountersManagerType.self)
            return RegisteredEncountersDebugModel(encountersManager: encountersManager)
        }
    }

    private func registerRegisteredEncountersDebugViewModel(_ container: Container) {
        container.register(RegisteredEncountersDebugViewModelType.self) { resolver in
            let model: RegisteredEncountersDebugModelType = resolver.resolve(RegisteredEncountersDebugModelType.self)
            return RegisteredEncountersDebugViewModel(model: model)
        }
    }

    private func registerRegisteredEncountersDebugViewController(_ container: Container) {
        container.register(RegisteredEncountersDebugViewController.self) { resolver in
            let viewModel: RegisteredEncountersDebugViewModelType =
                resolver.resolve(RegisteredEncountersDebugViewModelType.self)
            return RegisteredEncountersDebugViewController(viewModel: viewModel)
        }
    }
}
