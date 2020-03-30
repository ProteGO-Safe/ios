import Swinject

final class BluetoothAssembly: Assembly {

    func assemble(container: Container) {
        registerBluetoothAdvertiser(container)
        registerBluetoothScanner(container)
        registerBluetoothBackgroundTask(container)
    }

    private func registerBluetoothAdvertiser(_ container: Container) {
        container.register(Advertiser.self) { (resolver, delegate: AdvertiserDelegate) in
            if DebugMenu.assign(DebugMenu.useMockBluetoothAdvertiser) {
                return MockAdvertiser(delegate: delegate)
            } else {
                let backgroundTask: BluetoothBackgroundTask = resolver.resolve(BluetoothBackgroundTask.self)
                return BleAdvertiser(delegate: delegate, backgroundTask: backgroundTask)
            }
        }.inObjectScope(.container)
    }

    private func registerBluetoothScanner(_ container: Container) {
        container.register(Scanner.self) { (resolver, delegate: ScannerDelegate) in
            if DebugMenu.assign(DebugMenu.useMockBluetoothScanner) {
                return MockScanner(delegate: delegate)
            } else {
                let backgroundTask: BluetoothBackgroundTask = resolver.resolve(BluetoothBackgroundTask.self)
                return BleScanner(delegate: delegate, backgroundTask: backgroundTask)
            }
        }.inObjectScope(.container)
    }

    private func registerBluetoothBackgroundTask(_ container: Container) {
        container.register(BluetoothBackgroundTask.self) { _ in
            return BluetoothBackgroundTask()
        }.inObjectScope(.container)
    }
}
