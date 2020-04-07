import Swinject
import Valet

final class GeneralAssembly: Assembly {

    func assemble(container: Container) {
        registerRealm(container)
        registerFilesCoordinator(container)
        registerSecretsGenerator(container)
        registerKeychainProvider(container)
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
            return SecretsGenerator(keychainProvider: resolver.resolve(KeychainProviderType.self))
        }
    }

    private func registerKeychainProvider(_ container: Container) {
        container.register(KeychainProviderType.self) { _ in
            guard let sandboxId = Identifier(nonEmpty: Constants.ValetSandboxIds.secrets) else {
                logger.error("Fatal error: failed to generate Kaychain Id")
                fatalError()
            }

            return KeychainProvider(identifier: sandboxId, accessibility: .afterFirstUnlock)
        }.inObjectScope(.container)
    }

    private func registerEncountersManager(_ container: Container) {
        container.register(EncountersManagerType.self) { resolver in
            let realmManager: RealmManagerType  = resolver.resolve(RealmManagerType.self)

            return EncountersManager(realmManager: realmManager)
        }.inObjectScope(.container)
    }

    private func registerDangerStatusManager(_ container: Container) {
        container.register(DangerStatusManagerType.self) { resolver in
            return DangerStatusManager(gcpClient: resolver.resolve(GcpClientType.self),
                                       keychainProvider: resolver.resolve(KeychainProviderType.self))
        }.inObjectScope(.container)
    }

    private func registerDefaultsService(_ container: Container) {
        container.register(DefaultsServiceType.self) { _ in
            return DefaultsService()
        }.inObjectScope(.container)
    }
}
