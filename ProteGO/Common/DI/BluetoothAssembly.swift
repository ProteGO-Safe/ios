import Swinject

final class BluetoothAssembly: Assembly {

    func assemble(container: Container) {
        registerBeaconIdAgent(container)
        registerBluetoothAdvertiser(container)
        registerBluetoothScanner(container)
        registerBluetoothBackgroundTask(container)
    }

    private func registerBeaconIdAgent(_ container: Container) {
        container.register(BeaconIdAgentType.self) { (resolver) in
            return BeaconIdAgent(encountersManager: resolver.resolve(EncountersManagerType.self),
                                 beaconIdsManager: resolver.resolve(BeaconIdsManagerType.self),
                                 currentDateProvider: CurrentDateProvider())
        }.inObjectScope(.container)
    }

    private func registerBluetoothAdvertiser(_ container: Container) {
        container.register(Advertiser.self) { (resolver, agent: BeaconIdAgentType) in
            if DebugMenu.assign(DebugMenu.useMockBluetoothAdvertiser) {
                return MockAdvertiser(agent: agent)
            } else {
                let backgroundTask: BluetoothBackgroundTask = resolver.resolve(BluetoothBackgroundTask.self)
                return BleAdvertiser(agent: agent, backgroundTask: backgroundTask)
            }
        }.inObjectScope(.container)
    }

    private func registerBluetoothScanner(_ container: Container) {
        container.register(Scanner.self) { (resolver, agent: BeaconIdAgentType) in
            if DebugMenu.assign(DebugMenu.useMockBluetoothScanner) {
                return MockScanner(agent: agent)
            } else {
                let backgroundTask: BluetoothBackgroundTask = resolver.resolve(BluetoothBackgroundTask.self)
                return BleScanner(agent: agent, backgroundTask: backgroundTask)
            }
        }.inObjectScope(.container)
    }

    private func registerBluetoothBackgroundTask(_ container: Container) {
        container.register(BluetoothBackgroundTask.self) { _ in
            return BluetoothBackgroundTask()
        }.inObjectScope(.container)
    }
}
