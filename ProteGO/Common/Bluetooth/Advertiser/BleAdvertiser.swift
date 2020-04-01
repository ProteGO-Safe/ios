import Foundation
import CoreBluetooth

class BleAdvertiser: NSObject, CBPeripheralManagerDelegate, Advertiser {
    /// Main peripheral manager.
    private var peripheralManager: CBPeripheralManager!
    /// Handle to the currently mounted service
    private var service: CBService?
    /// Delegate
    private weak var delegate: AdvertiserDelegate?
    /// Current Beacon ID to advertise.
    private var currentBeaconId: (BeaconId, Date)?
    /// Advertisement timer to schedule start/stop operations.
    private var advertisementTimer: Timer?
    /// Advertising mode deciding about radio usage.
    private var mode: AdvertiserMode = .Disabled
    /// Background processing task handle.
    private let backgroundTask: BluetoothBackgroundTask
    private let advertisementTaskID = Constants.Bluetooth.AdvertisingBackgroundTaskID

    /// Restoration identifier is required to properly resume when application is restored by the OS.
    init(delegate: AdvertiserDelegate, backgroundTask: BluetoothBackgroundTask) {
        self.backgroundTask = backgroundTask
        super.init()
        self.delegate = delegate
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [
            CBPeripheralManagerOptionRestoreIdentifierKey:
                Constants.Bluetooth.BluetoothPeripheralManagerRestorationID
        ])
    }

    /// Set advertiser mode deciding how long advertisement is turned on and off.
    /// - Parameter mode: Advertiser mode
    func setMode(_ mode: AdvertiserMode) {
        logger.debug("Advertisement mode: \(mode)")
        self.mode = mode
        switch mode {
        case .Disabled:
            stopAdvertisementIfNeeded()
        default:
            startAdvertisementIfNeeded()
        }
    }

    /// Returns advertiser's mode
    func getMode() -> AdvertiserMode {
        return self.mode
    }

    /// Returns true if advertising
    func isAdvertising() -> Bool {
        return self.peripheralManager.state == .poweredOn && self.peripheralManager.isAdvertising
    }

    /// Initialize GATT server database. By default all ProteGO devices have one specific service and
    /// characteristic. Characteristic is readonly and returns device information. When no device information
    /// is present characteristic returns zero length byte slice.
    private func createLocalDatabase() -> CBMutableService {
        // Define ProteGO characteristic
        let characteristic = CBMutableCharacteristic(
          type: Constants.Bluetooth.ProteGOCharacteristicUUID,
          properties: [.read, .write, .writeWithoutResponse],
          value: nil,
          permissions: [.readable, .writeable]
        )

        // Define ProteGO service
        let service = CBMutableService(
          type: Constants.Bluetooth.ProteGOServiceUUID,
          primary: true
        )
        service.characteristics = [characteristic]

        return service
    }

    /// Start advertisement. In the background we can only advertise UUID, which is then stored in special "overflow" area
    /// visible only to other iOS devices.
    private func startAdvertisementIfNeeded() {
        logger.debug("Starting advertisement if needed")

        // start a task
        backgroundTask.start(taskName: advertisementTaskID)

        // Stop advertisement timer.
        self.advertisementTimer?.invalidate()
        self.advertisementTimer = nil

        switch self.mode {
        case .Disabled:
            // We can't enable advertisement
            logger.debug("Advertisement is disabled")
            return
        case .EnabledAllTime:
            // We don't setup timers to stop advertisement.
            break
        case let .EnabledPartTime(advertisingOnTime: onTime, advertisingOffTime: _):
            // Setup timer to stop advertisement.
            let timer = Timer.init(timeInterval: onTime, repeats: false) { [weak self] _ in
                self?.stopAdvertisementIfNeeded()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.advertisementTimer = timer
        }

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
        logger.debug("Stopping advertisement if needed")

        // Stop background task.
        backgroundTask.stop(taskName: advertisementTaskID)

        // Stop advertising timer.
        self.advertisementTimer?.invalidate()
        self.advertisementTimer = nil

        // Check advertisement mode.
        switch self.mode {
        case .Disabled:
            // Let't stop advertising if needed.
            break
        case .EnabledAllTime:
            // Don't allow to stop advertisement.
            logger.debug("Advertisement is always enabled.")
            return
        case let .EnabledPartTime(advertisingOnTime: _, advertisingOffTime: offTime):
            // Setup advertisement timer to start after a while
            let timer = Timer.init(timeInterval: offTime, repeats: false) { [weak self] _ in
                self?.startAdvertisementIfNeeded()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.advertisementTimer = timer
        }

        if peripheralManager.state == .poweredOn && peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }
    }

    /// Check if Beacon ID is present and not expired.
    private func beaconIdIsValid() -> Bool {
        guard let beaconId = self.currentBeaconId else {
            return false
        }
        return beaconId.1 > Date()
    }

    /// Update Beacon ID.
    func updateBeaconId(beaconId: BeaconId, expirationDate: Date) {
        logger.debug("Beacon ID (\(beaconId)) updated with expiration date: \(expirationDate)")
        self.currentBeaconId = (beaconId, expirationDate)
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

        // Marker if Beacon ID was expired during this transaction.
        var beaconIdExpired = false

        // Check if token data is valid. If not, allow delegate to udpate
        if !beaconIdIsValid() {
            delegate?.beaconIdExpired(previousBeaconId: self.currentBeaconId)
            beaconIdExpired = true
        }

        // Check once again if Beacon ID is valid.
        guard let (beaconId, _) = self.currentBeaconId, self.beaconIdIsValid() else {
            // If not, return that read is not permitted.
            peripheral.respond(to: request, withResult: .readNotPermitted)
            return
        }

        // Continue transaction when Beacon ID was not expired or request offset was set to 0.
        guard !beaconIdExpired || request.offset == 0 else {
            // Read is not permitted.
            peripheral.respond(to: request, withResult: .readNotPermitted)
            return
        }

        // Check if offset is not out of band.
        guard request.offset <  beaconId.getData().count else {
            logger.debug("Invalid offset: \(request.offset)")
            peripheral.respond(to: request, withResult: .invalidOffset)
            return
        }

        // Setup value and respond.
        request.value = beaconId.getData().subdata(in: request.offset ..< beaconId.getData().count)
        peripheral.respond(to: request, withResult: .success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        logger.debug("Peripheral manager did receive write(s)")
        for request in requests {
            // Does it look like we can't distinguish partial writes from normal writes? Let's ignore
            // writes with offset != 0.
            guard let value = request.value, request.offset == 0 else {
                peripheralManager.respond(to: request, withResult: .writeNotPermitted)
                continue
            }

            // If data is a valid Beacon ID, let's inform user about it.
            logger.debug("write: \(value.toHexString()) from: \(request.central.identifier)")
            if let beaconId = BeaconId(data: value) {
                delegate?.synchronizedBeaconId(beaconId: beaconId, rssi: nil)
                peripheralManager.respond(to: request, withResult: .success)
                continue
            }

            // Invalid data was sent.
            peripheralManager.respond(to: request, withResult: .writeNotPermitted)
        }
    }
}
