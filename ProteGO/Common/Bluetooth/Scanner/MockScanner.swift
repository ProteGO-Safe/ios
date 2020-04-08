import Foundation

class MockScanner: Scanner {
    private weak var agent: BeaconIdAgentType?
    private var mode: ScannerMode = .disabled

    init(agent: BeaconIdAgentType) {
        self.agent = agent
        let timer = Timer.init(
            timeInterval: TimeInterval(DebugMenu.assign(DebugMenu.mockBluetoothScannerInterval)),
            repeats: true) { [weak self] _ in
                self?.agent?.synchronizedBeaconId(beaconId: BeaconId.random(), rssi: Int.random(in: (-40)..<(-140)))
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    func setMode(_ mode: ScannerMode) {
        self.mode = mode
    }

    func getMode() -> ScannerMode {
        return self.mode
    }

    func isScanning() -> Bool {
        switch self.mode {
        case .disabled:
            return false
        default:
            return true
        }
    }
}
