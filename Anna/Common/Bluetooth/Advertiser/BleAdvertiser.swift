import Foundation
import CoreBluetooth

class BleAdvertiser: NSObject, CBPeripheralManagerDelegate, Advertiser {
    /// Main peripheral manager.
    private var peripheralManager: CBPeripheralManager!
    /// Handle to the currently mounted service
    private var service: CBService?
    /// Delegate
    weak var delegate: AdvertiserDelegate?
    /// Current token data
    var currentTokenData: (Data, Date)?

    /// Restoration identifier is required to properly resume when application is restored by the OS.
    init(delegate: AdvertiserDelegate) {
        super.init()
        self.delegate = delegate
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [
            CBPeripheralManagerOptionRestoreIdentifierKey: Constants.Bluetooth.AnnaServiceUUID
        ])
    }

    /// NOTE:  Add mechnism to restart advertisement when something goeas wrong.
    private func scheduleRestartIfNeeded() {

    }

    /// NOTE: Add code responsible for monitoring health of advertiser. Check in specific intervals
    /// if device is actually advertising and there are tokens available.
    private func initializeHealthCheckIfNeeded() {

    }

    /// Initialize GATT server database. By default all Anna devices have one specific semonirvice and
    /// characteristic. Characteristic is readonly and returns device information. When no device information
    /// is present characteristic returns zero length byte slice.
    private func createLocalDatabase() -> CBMutableService {
        // Define Anna characteristic
        let characteristicUUID = Constants.Bluetooth.AnnaCharacteristicUUID
        let characteristicProps = CBCharacteristicProperties.read
        let characteristicPerm = CBAttributePermissions.readable
        let characteristic = CBMutableCharacteristic(
          type: characteristicUUID,
          properties: characteristicProps,
          value: nil,
          permissions: characteristicPerm
        )

        // Define Anna service
        let serviceUUID = Constants.Bluetooth.AnnaServiceUUID
        let service = CBMutableService(
          type: serviceUUID,
          primary: true
        )
        service.characteristics = [characteristic]

        return service
    }

    /// Start advertisement. In the background we can only advertise UUID, which is then stored in special "overflow" area
    /// visible only to other iOS devices.
    private func startAdvertisementIfNeeded() {
        if peripheralManager.state == .poweredOn && !peripheralManager.isAdvertising {
            peripheralManager.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [Constants.Bluetooth.AnnaServiceUUID]
            ])
        }
    }

    /// Check if token data is present and not expired.
    private func tokenDataIsValid() -> Bool {
        guard let tokenData = self.currentTokenData else {
            return false
        }
        return tokenData.1 > Date()
    }

    /// Update token data.
    public func updateTokenData(data: Data, expirationDate: Date) {
        logger.debug("Token data updated with expiration date: \(expirationDate)")
        self.currentTokenData = (data, expirationDate)
    }

    // State management ---------------------------------------------------------------------------------

    /// This is the first callback called when we are restoring previous state.
    /// Make sure to not call any CoreBluetooth methods yet, as we need to
    /// wait for 'PoweredOn' state to do that.
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String: Any]) {
        logger.debug("Peripheral manager will restore state")
        // We don't need to add services as they should be already there.
        let services: [CBMutableService]? = dict[CBPeripheralManagerRestoredStateServicesKey] as? [CBMutableService]
        self.service = services?.first { $0.uuid == Constants.Bluetooth.AnnaServiceUUID }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        logger.debug("Peripheral manager did add service, error: \(String(describing: error))")
        if error == nil {
            // After service is ready to use, start advertising.
            self.service = service
            startAdvertisementIfNeeded()
        } else {
            // Something went wrong. Consider restarting.
            scheduleRestartIfNeeded()
        }
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        logger.debug("Peripheral manager did update state \(peripheral.state.rawValue)")
        if peripheral.state == .poweredOn {
            // We can only use API when Bluetooth is powered On.
            if self.service == nil {
                // When service is not mounted add one.
                let newService = createLocalDatabase()
                self.peripheralManager.add(newService)
            } else {
                // Otherwise we are ready to start advertisement.
                startAdvertisementIfNeeded()
            }
        } else {
            // Clenup state and register everything once again when we get back to 'PoweredOn'
            peripheral.removeAllServices()
            self.service = nil
        }
    }

    // Advertising ---------------------------------------------------------------------------------------------

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        logger.debug("Peripheral manager did start advertising, error: \(String(describing: error))")
        // If we fail to start advertisement, try again later.
        if error != nil {
            scheduleRestartIfNeeded()
        }
    }

    // Characteristics -----------------------------------------------------------------------------------------

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        logger.debug("Peripheral manager did receive read, offset: \(request.offset)")

        // Marker if token data was expired during this transaction.
        var tokenExpired = false

        // Check if token data is valid. If not, allow delegate to udpate
        if !tokenDataIsValid() {
            delegate?.tokenDataExpired(previousTokenData: self.currentTokenData)
            tokenExpired = true
        }

        // Check once again if data is valid.
        guard let tokenData = self.currentTokenData, self.tokenDataIsValid() else {
            // If not, return that read is not permitted.
            peripheral.respond(to: request, withResult: CBATTError.readNotPermitted)
            return
        }

        // Continue transaction when token was not expired or request offset was set to 0.
        guard !tokenExpired || request.offset == 0 else {
            // Read is not permitted.
            peripheral.respond(to: request, withResult: CBATTError.readNotPermitted)
            return
        }

        // Check if offset is not out of band.
        guard request.offset < tokenData.0.count else {
            logger.debug("Invalid offset: \(request.offset)")
            peripheral.respond(to: request, withResult: CBATTError.invalidOffset)
            return
        }

        // Setup value and respond.
        request.value = tokenData.0.subdata(in: request.offset ..< tokenData.0.count)
        peripheral.respond(to: request, withResult: CBATTError.success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        logger.debug("Peripheral manager did receive write")
        // Reject all writes.
        for request in requests {
            peripheralManager.respond(to: request, withResult: CBATTError.writeNotPermitted)
        }
    }
}
