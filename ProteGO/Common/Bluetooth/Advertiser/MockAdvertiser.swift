import Foundation

class MockAdvertiser: Advertiser {
    var previousTokenData: (Data, Date)?
    weak var delegate: AdvertiserDelegate?

    init(delegate: AdvertiserDelegate) {
        self.delegate = delegate
        let timer = Timer.init(timeInterval:
        TimeInterval(DebugMenu.assign(DebugMenu.mockBluetoothAdvertiserInterval)), repeats: true) { [weak self] _ in
            if let tokenData = self?.previousTokenData {
                if tokenData.1 < Date() {
                    self?.delegate?.tokenDataExpired(previousTokenData: self?.previousTokenData)
                }
            } else {
                self?.delegate?.tokenDataExpired(previousTokenData: self?.previousTokenData)
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    public func updateTokenData(data: Data, expirationDate: Date) {
        self.previousTokenData = (data, expirationDate)
    }
}
