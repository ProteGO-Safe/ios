import Foundation

class MockScanner: Scanner {
    weak var delegate: ScannerDelegate?

    init(delegate: ScannerDelegate) {
        self.delegate = delegate
        let timer = Timer.init(
            timeInterval: TimeInterval(DebugMenu.assign(DebugMenu.mockBluetoothScannerInterval)),
            repeats: true) { [weak self] _ in
                self?.delegate?.synchronizedTokenData(data: Data([0xff]), rssi: -80)
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}
