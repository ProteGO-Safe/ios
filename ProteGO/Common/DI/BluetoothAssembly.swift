import Swinject

final class BluetoothAssembly: Assembly {

    func assemble(container: Container) {
        registerBluetoothAdvertiser(container)
        registerBluetoothScanner(container)
        registerBluetoothBackgroundTask(container)
    }

    private func registerBluetoothAdvertiser(_ container: Container) {
        container.register(Advertiser.self) { (resolver, agent: BeaconIdAgent) in
            if DebugMenu.assign(DebugMenu.useMockBluetoothAdvertiser) {
                return MockAdvertiser(agent: agent)
            } else {
                let backgroundTask: BluetoothBackgroundTask = resolver.resolve(BluetoothBackgroundTask.self)
                return BleAdvertiser(agent: agent, backgroundTask: backgroundTask)
            }
        }.inObjectScope(.container)
    }

    private func registerBluetoothScanner(_ container: Container) {
        container.register(Scanner.self) { (resolver, agent: BeaconIdAgent) in
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
