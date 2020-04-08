import Swinject

final class DebugAssembly: Assembly {

    func assemble(container: Container) {
        registerRegisteredEncountersDebugModel(container)
        registerRegisteredEncountersDebugViewModel(container)
        registerRegisteredEncountersDebugViewController(container)
        registerRegisteredBeaconIdsDebugModel(container)
        registerRegisteredBeaconIdsDebugViewModel(container)
        registerRegisteredBeaconIdsDebugViewController(container)
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

    private func registerRegisteredBeaconIdsDebugModel(_ container: Container) {
          container.register(RegisteredBeaconIdsDebugScreenModelType.self) { resolver in
              let beaconIdsManager: BeaconIdsManagerType = resolver.resolve(BeaconIdsManagerType.self)
              return RegisteredBeaconIdsDebugScreenModel(beaconIdsManager: beaconIdsManager)
          }
      }

      private func registerRegisteredBeaconIdsDebugViewModel(_ container: Container) {
          container.register(RegisteredBeaconIdsDebugScreenViewModelType.self) { resolver in
              let model: RegisteredBeaconIdsDebugScreenModelType =
                resolver.resolve(RegisteredBeaconIdsDebugScreenModelType.self)
              return RegisteredBeaconIdsDebugScreenViewModel(model: model)
          }
      }

      private func registerRegisteredBeaconIdsDebugViewController(_ container: Container) {
          container.register(RegisteredBeaconIdsDebugViewController.self) { resolver in
              let viewModel: RegisteredBeaconIdsDebugScreenViewModelType =
                  resolver.resolve(RegisteredBeaconIdsDebugScreenViewModelType.self)
              return RegisteredBeaconIdsDebugViewController(viewModel: viewModel)
          }
      }
}
