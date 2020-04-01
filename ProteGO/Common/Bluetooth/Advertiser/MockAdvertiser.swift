import Foundation

class MockAdvertiser: Advertiser {
    private var mode: AdvertiserMode = .Disabled
    private var previousBeaconId: (BeaconId, Date)?
    private weak var delegate: AdvertiserDelegate?

    init(delegate: AdvertiserDelegate) {
        self.delegate = delegate
        let timer = Timer.init(timeInterval:
        TimeInterval(DebugMenu.assign(DebugMenu.mockBluetoothAdvertiserInterval)), repeats: true) { [weak self] _ in
            if let tokenData = self?.previousBeaconId {
                if tokenData.1 < Date() {
                    self?.delegate?.beaconIdExpired(previousBeaconId: self?.previousBeaconId)
                }
            } else {
                self?.delegate?.beaconIdExpired(previousBeaconId: self?.previousBeaconId)
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    func updateBeaconId(beaconId: BeaconId, expirationDate: Date) {
        self.previousBeaconId = (beaconId, expirationDate)
    }

    func setMode(_ mode: AdvertiserMode) {
        self.mode = mode
    }

    func getMode() -> AdvertiserMode {
        return self.mode
    }

    func isAdvertising() -> Bool {
        if case .Disabled = self.mode {
            return false
        }
        return true
    }
}
