import Swinject
import Valet

final class GeneralAssembly: Assembly {

    func assemble(container: Container) {
        registerRealm(container)
        registerFilesCoordinator(container)
        registerSecretsGenerator(container)
        registerEncountersManager(container)
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
        container.register(SecretsGeneratorType.self) { _ in
            //swiftlint:disable force_unwrapping
            let valet = Valet.valet(with: Identifier(nonEmpty: "Secrets")!, accessibility: .afterFirstUnlock)
            return SecretsGenerator(valet: valet)
        }
    }

    private func registerEncountersManager(_ container: Container) {
        container.register(EncountersManagerType.self) { resolver in
            let realmManager: RealmManagerType  = resolver.resolve(RealmManagerType.self)

            return EncountersManager(realmManager: realmManager)
        }.inObjectScope(.container)
    }
}
