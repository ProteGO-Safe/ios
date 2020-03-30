import Foundation
import CoreBluetooth

class BleAdvertiser: NSObject, CBPeripheralManagerDelegate, Advertiser {
    /// Main peripheral manager.
    private var peripheralManager: CBPeripheralManager!
    /// Handle to the currently mounted service
    private var service: CBService?
    /// Delegate
    private weak var delegate: AdvertiserDelegate?
    /// Current token data
    private var currentTokenData: (Data, Date)?
    /// Advertisement restart timer. After a timeout we restart advertising.
    private var advertisementRestartTimer: Timer?
    /// Advertisement stop timer. After a timeout we stop advertisement.
    private var advertisementStopTimer: Timer?
    /// Background processing task handle.
    private let backgroundTask: BluetoothBackgroundTask
    private let advertisementTaskID = Constants.Bluetooth.AdvertisingBackgroundTaskID

    /// Restoration identifier is required to properly resume when application is restored by the OS.
    init(delegate: AdvertiserDelegate, backgroundTask: BluetoothBackgroundTask) {
        self.backgroundTask = backgroundTask
        super.init()
        self.delegate = delegate
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [
            CBPeripheralManagerOptionRestoreIdentifierKey: Constants.Bluetooth.ProteGOServiceUUID
        ])
    }

    /// Initialize GATT server database. By default all ProteGO devices have one specific service and
    /// characteristic. Characteristic is readonly and returns device information. When no device information
    /// is present characteristic returns zero length byte slice.
    private func createLocalDatabase() -> CBMutableService {
        // Define ProteGO characteristic
        let characteristicUUID = Constants.Bluetooth.ProteGOCharacteristicUUID
        let characteristicProps = CBCharacteristicProperties.read
        let characteristicPerm = CBAttributePermissions.readable
        let characteristic = CBMutableCharacteristic(
          type: characteristicUUID,
          properties: characteristicProps,
          value: nil,
          permissions: characteristicPerm
        )

        // Define ProteGO service
        let serviceUUID = Constants.Bluetooth.ProteGOServiceUUID
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
        logger.debug("Starting advertisement")

        // start a task
        backgroundTask.start(taskName: advertisementTaskID)

        // Restart advertisement stop timer.
        self.advertisementStopTimer?.invalidate()
        let newAdvertisementStopTimer = Timer.init(
            timeInterval: Constants.Bluetooth.AdvertisingStopTimeout,
            repeats: false) { [weak self] _ in
                self?.stopAdvertisementIfNeeded()
        }
        RunLoop.main.add(newAdvertisementStopTimer, forMode: .common)
        self.advertisementStopTimer = newAdvertisementStopTimer

        // Restart advertisement restart timer.
        self.advertisementRestartTimer?.invalidate()
        let newAdvertisementRestartTimer = Timer.init(
            timeInterval: Constants.Bluetooth.AdvertisingRestartTimeout,
            repeats: false) { [weak self] _ in
                self?.startAdvertisementIfNeeded()
        }
        RunLoop.main.add(newAdvertisementRestartTimer, forMode: .common)
        self.advertisementRestartTimer = newAdvertisementRestartTimer

        // Enable advertising if needed.
        if peripheralManager.state == .poweredOn && !peripheralManager.isAdvertising {
            peripheralManager.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [Constants.Bluetooth.ProteGOServiceUUID]
            ])
        }
    }

    /// Stop advertisement. We want to limit power consumption in the background to keep our application running for
    /// a longer time.
    private func stopAdvertisementIfNeeded() {
        logger.debug("Stopping advertisement")
        backgroundTask.stop(taskName: advertisementTaskID)
        if peripheralManager.state == .poweredOn && peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
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
        self.service = services?.first { $0.uuid == Constants.Bluetooth.ProteGOServiceUUID }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        logger.debug("Peripheral manager did add service, error: \(String(describing: error))")
        if error == nil {
            // After service is ready to use, start advertising.
            self.service = service
            self.startAdvertisementIfNeeded()
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
            self.stopAdvertisementIfNeeded()
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
