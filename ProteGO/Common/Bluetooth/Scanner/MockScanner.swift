import Foundation

class MockScanner: Scanner {
    weak var delegate: ScannerDelegate?

    init(delegate: ScannerDelegate) {
        self.delegate = delegate
        let timer = Timer.init(
            timeInterval: TimeInterval(DebugMenu.assign(DebugMenu.mockBluetoothScannerInterval)),
            repeats: true) { [weak self] _ in
                self?.delegate?.synchronizedBeaconId(beaconId: BeaconId.random(), rssi: Int.random(in: (-40)..<(-140)))
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}
