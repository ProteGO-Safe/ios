import Foundation

class MockAdvertiser: Advertiser {
    private var mode: AdvertiserMode = .Disabled
    private var expiringBeaconId: ExpiringBeaconId?
    private weak var agent: BeaconIdAgent?

    init(agent: BeaconIdAgent) {
        self.agent = agent
        let timer = Timer.init(timeInterval:
        TimeInterval(DebugMenu.assign(DebugMenu.mockBluetoothAdvertiserInterval)), repeats: true) { [weak self] _ in
            if let self = self {
                if self.expiringBeaconId?.isExpired() ?? true {
                    self.expiringBeaconId = self.agent?.getBeaconId()
                }
            }
        }
        RunLoop.current.add(timer, forMode: .common)
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
