import Swinject
import Valet

final class GeneralAssembly: Assembly {

    func assemble(container: Container) {
        registerRealm(container)
        registerFilesCoordinator(container)
        registerSecretsGenerator(container)
        registerValet(container)
        registerEncountersManager(container)
        registerDangerStatusManager(container)
        registerDefaultsService(container)
    }

    private func registerRealm(_ container: Container) {
        container.register(RealmManagerType.self) { resolver in
            let filesCoordinator: FilesCoordinatorType = resolver.resolve(FilesCoordinatorType.self)
            let secretsGenerator: SecretsGeneratorType = resolver.resolve(SecretsGeneratorType.self)

            return RealmManager(realmFilePath: filesCoordinator.realmFilePath, secretsGenerator: secretsGenerator)
        }
    }

    private func registerFilesCoordinator(_ container: Container) {
        container.register(FilesCoordinatorType.self) { _ in
            let fileManager = FileManager.default
            return FilesCoordinator(fileManager: fileManager)
        }
    }

    private func registerSecretsGenerator(_ container: Container) {
        container.register(SecretsGeneratorType.self) { resolver in
            return SecretsGenerator(valet: resolver.resolve(Valet.self))
        }
    }

    private func registerValet(_ container: Container) {
        container.register(Valet.self) { _ in
            //swiftlint:disable force_unwrapping
            let sandboxId = Identifier(nonEmpty: Constants.ValetSandboxIds.secrets)!
            return Valet.valet(with: sandboxId, accessibility: .afterFirstUnlock)
        }.inObjectScope(.container)
    }

    private func registerEncountersManager(_ container: Container) {
        container.register(EncountersManagerType.self) { resolver in
            let realmManager: RealmManagerType  = resolver.resolve(RealmManagerType.self)

            return EncountersManager(realmManager: realmManager)
        }.inObjectScope(.container)
    }

    private func registerDangerStatusManager(_ container: Container) {
        container.register(DangerStatusManagerType.self) { _ in
            return DangerStatusManager()
        }.inObjectScope(.container)
    }

    private func registerDefaultsService(_ container: Container) {
        container.register(DefaultsServiceType.self) { _ in
            return DefaultsService()
        }.inObjectScope(.container)
    }
}
