import Swinject
import Valet

final class BluetoothAssembly: Assembly {

    func assemble(container: Container) {
        registerBluetoothAdvertiser(container)
        registerBluetoothScanner(container)
    }

    private func registerBluetoothAdvertiser(_ container: Container) {
        container.register(Advertiser.self) { (_, delegate: AdvertiserDelegate) in
            if DebugMenu.assign(DebugMenu.useMockBluetoothAdvertiser) {
                return MockAdvertiser(delegate: delegate)
            } else {
                return BleAdvertiser(delegate: delegate)
            }
        }.inObjectScope(.container)
    }

    private func registerBluetoothScanner(_ container: Container) {
        container.register(Scanner.self) { (_, delegate: ScannerDelegate) in
            if DebugMenu.assign(DebugMenu.useMockBluetoothScanner) {
                return MockScanner(delegate: delegate)
            } else {
                return BleScanner(delegate: delegate)
            }
        }.inObjectScope(.container)
    }
}
