import Foundation
import CoreBluetooth

class BleScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, Scanner {
    /// CBCentral manager
    private var centralManager: CBCentralManager!

    /// Beacon ID agent providing new Beacon IDs.
    private weak var agent: BeaconIdAgentType?

    /// List of known devices
    private var devices: [ProteGoDeviceId: ProteGoDevice]

    /// Scanning timer controling on/off state of the scanner.
    private var scanningTimer: Timer?

    /// Scanner mode deciding about enabled/disabled state of discovery.
    private var mode: ScannerMode = .disabled

    /// Background task handle
    private let backgroundTask: BluetoothBackgroundTask
    private let scanningTaskID = Constants.Bluetooth.ScanningBackgroundTaskID

    /// Initialize Central Manager with restored state identifier to be able to work in the background.
    init(agent: BeaconIdAgentType, backgroundTask: BluetoothBackgroundTask) {
        self.backgroundTask = backgroundTask
        self.devices = [:]
        super.init()
        self.agent = agent
        let options = [CBCentralManagerOptionRestoreIdentifierKey: Constants.Bluetooth.BluetoothCentralManagerRestorationID]
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: options)

        /// This timer won't run in the background by itself. When we got time slice for
        /// execution make sure that synchronization checks are rare.
        let syncCheckTimer = Timer.init(
            timeInterval: Constants.Bluetooth.PeripheralSynchronizationCheckInSec,
            repeats: true) { [weak self] _ in
            self?.checkSynchronizationStatus()
        }
        RunLoop.current.add(syncCheckTimer, forMode: .common)
    }

    /// Set scanner mode
    /// - Parameter mode: Scanner mode
    func setMode(_ mode: ScannerMode) {
        logger.debug("Scanner mode: \(mode)")
        self.mode = mode
        switch mode {
        case .disabled:
            stopScanningIfNeeded()
        case .enabledAllTime, .enabledPartTime:
            startScanningIfNeeded()
        }
    }

    /// Get scanner mode
    func getMode() -> ScannerMode {
        return self.mode
    }

    /// Returns true if scanner is discovering new devices
    func isScanning() -> Bool {
        return centralManager.state == .poweredOn && centralManager.isScanning
    }

    /// Handle events emitted by peripherals and central manager
    /// - Parameters:
    ///   - event: Device event to handle
    ///   - for: Device for which event is directed.
    //swiftlint:disable:next function_body_length
    private func handle(event: ProteGoDeviceEvent, for device: ProteGoDevice) {
        logger.debug("Handling event: \(event) for: \(device.getId())")

        let poweredOff = self.centralManager.state != .poweredOn
        let effects = device.handle(event: event)

        for effect in effects {
            logger.debug("Executing effect: \(effect)")

            switch effect {
            case .Remove:
                self.devices.removeValue(forKey: device.getId())

            case let .Close(peripheral):
                peripheral.delegate = nil
                if poweredOff { break }
                self.centralManager.cancelPeripheralConnection(peripheral)

            case let .Connect(peripheral):
                if poweredOff { break }
                self.centralManager.connect(peripheral, options: nil)

            case let .Disconnect(peripheral):
                self.backgroundTask.stop(taskName: device.getId().description)
                if poweredOff { break }
                self.centralManager.cancelPeripheralConnection(peripheral)

            case let .DiscoverServices(peripheral):
                if poweredOff || peripheral.state != .connected { break }
                peripheral.discoverServices([Constants.Bluetooth.ProteGOServiceUUID])

            case let .DiscoverCharacteristics(service):
                let peripheral = service.peripheral
                if poweredOff || peripheral.state != .connected { break }
                peripheral.discoverCharacteristics(
                    [Constants.Bluetooth.ProteGOCharacteristicUUID], for: service)

            case let .ReadRSSI(peripheral):
                if poweredOff || peripheral.state != .connected { break }
                peripheral.readRSSI()

            case let .ReadValue(characteristic):
                let peripheral = characteristic.service.peripheral
                if poweredOff || peripheral.state != .connected { break }
                peripheral.readValue(for: characteristic)

            case let .WriteValue(characteristic):
                let peripheral = characteristic.service.peripheral
                if poweredOff || peripheral.state != .connected { break }
                let data = self.agent?.getBeaconId()?.getBeaconId()?.getData()
                if let data = data {
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                } else {
                    self.centralManager.cancelPeripheralConnection(peripheral)
                }

            case let .SynchronizeBeaconId(beaconId):
                self.backgroundTask.stop(taskName: device.getId().description)
                self.agent?.synchronizedBeaconId(beaconId: beaconId, rssi: device.getLastRSSI())
            }
        }
    }

    /// Function parses manufacturer data to detect type of a device. If there is no manufacturer data it means that it's
    /// probably iOS device, which doesn't allow to do that. Otherwise we check if manufacturer data is from Polidea
    /// company and that there is complete or incomplete beacon id present.
    /// - Parameters:
    ///   - data: Manufacturer data
    ///   - peripheral: Involved peripheral
    /// - Returns: DeviceId based on the content of manufacturer data.
    private func parseDeviceIdFromManufacturerData(data: Data?, for peripheral: CBPeripheral) -> ProteGoDeviceId {
        // Construct expected manufacturer data prefix.
        // Company ID is in little endian.
        let prefix: [UInt8] = [
            UInt8((Constants.Bluetooth.PolideaCompanyId) & 0x00FF),
            UInt8((Constants.Bluetooth.PolideaCompanyId >> 8) & 0x00FF),
            UInt8(Constants.Bluetooth.PolideaProteGOManufacturerDataVersion)
        ]

        // Check if data exists
        guard let data = data else {
            return .PeripheralInstance(peripheral)
        }

        // Check if prefix is valid and at least one more byte is present
        guard data.count > prefix.count &&
              data.subdata(in: 0 ..< prefix.count).elementsEqual(prefix) else {
            return .PeripheralInstance(peripheral)
        }

        // Try convert to Beacon ID.
        let beaconIdData = data.subdata(in: prefix.count ..< data.count)
        if let beaconId = BeaconId(data: beaconIdData) {
            return .BeaconId(beaconId)
        }

        return .IncompleteBeaconId(beaconIdData)
    }

    /// Device was found by a central manager.
    /// - Parameters:
    ///   - device: Detected device
    ///   - rssi: Device's RSSI during discovery.
    ///   - manufacturerData: Manufacturer data found during discovery.
    private func deviceFound(peripheral: CBPeripheral, rssi: Int?, manufacturerData: Data?) {
        let debugDeviceId = peripheral.identifier
        let debugRSSI = String(describing: rssi)
        let debugData = String(describing: manufacturerData?.toHexString())
        logger.debug("Device found: \(debugDeviceId) rssi: \(debugRSSI) manu: \(debugData)")

        // Construct device ID from manufacturer data if present
        let deviceId = self.parseDeviceIdFromManufacturerData(
            data: manufacturerData,
            for: peripheral
        )

        // Setup delegate on this peripheral as it will be used
        peripheral.delegate = self

        // Check if there is a device with this ID
        if let device = self.devices[deviceId] {
            // Update information about the device
            let oldPeripheral = device.updateDeviceWith(peripheral: peripheral)
            oldPeripheral?.delegate = nil
        } else {
            // Create a new device
            let device = ProteGoDevice(id: deviceId, peripheral: peripheral)
            self.devices[deviceId] = device
        }

        // Update RSSI and synchronize Beacon ID if possible.
        if let rssi = rssi, let beaconId = self.devices[deviceId]?.updateRSSI(rssi: rssi) {
            agent?.synchronizedBeaconId(beaconId: beaconId, rssi: rssi)
        }

        // Check if we need to synchronize.
        startSynchronizationIfNeeded()
    }

    /// Utility function to find device by an active peripheral instance
    /// - Parameter peripheral: Active peripheral instance of a device
    private func getDeviceBy(peripheral: CBPeripheral) -> ProteGoDevice? {
        return self.devices.first { $0.value.isPeripheralActive(peripheral: peripheral) }?.value
    }

    /// This method is called every time interval to check the state of a connection.
    private func checkSynchronizationStatus() {
        logger.debug("Check synchronization status")

        // Finish synchronization which timed out.
        cancelSynchronization(onlyOnTimeout: true)

        // Start synchronization if needed
        startSynchronizationIfNeeded()
    }

    /// This method is called when we want to stop synchronization.
    private func cancelSynchronization(onlyOnTimeout: Bool) {
        for device in self.devices.values {
            handle(event: .SynchronizationCancelled(onlyOnTimeout), for: device)
        }
    }

    /// This function is called when there is an event, which could change state deciding about
    /// a need to synchronize.
    private func startSynchronizationIfNeeded() {
        // Make sure we are powered on.
        guard self.centralManager.state == .poweredOn else {
            return
        }

        // Get list of devices and sort it by a a connection priority
        let sortedDevices = self.devices.values.sorted { (a, b) in
            a.hasHigherPriorityForConnection(other: b)
        }

        // Check number of pending connections
        var freeSlots = DebugMenu.assign(DebugMenu.bluetoothMaxConcurrentConnections)
        sortedDevices.forEach { device in
            // Get debug info
            logger.debug(device.description)

            // Remove from slot if device is not ready to connect.
            if !device.isIdle() && freeSlots > 0 {
                freeSlots -= 1
            }
        }

        // If ready to connect, let's start synchronization.
        for i in 0..<freeSlots where i < sortedDevices.count {
            let device = sortedDevices[i]
            if device.isReadyToConnect() {
                handle(event: .SynchronizationStarted, for: device)
            }
        }
    }

    private func startScanningIfNeeded() {
        logger.debug("Starting scanning...")

        // Start scanning background task
        backgroundTask.start(taskName: scanningTaskID)

        // Stop scanning timer
        self.scanningTimer?.invalidate()
        self.scanningTimer = nil

        // Check scanning mode.
        switch self.mode {
        case .disabled:
            // Scanning is disabled, don't allow starting.
            logger.debug("Scanning failed to start as scanner is disabled")
            return
        case .enabledAllTime:
            // Scanning is enabled, all time, no need to setup timer.
            break
        case let .enabledPartTime(scanningOnTime: onTime, scanningOffTime: _):
            // Prepare timer to stop scanning
            let timer = Timer.init(timeInterval: onTime, repeats: false) { [weak self] _ in
                self?.stopScanningIfNeeded()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.scanningTimer = timer
        }

        // Start scanning if needed.
        if self.centralManager.state == .poweredOn && !self.centralManager.isScanning {
            self.centralManager.scanForPeripherals(withServices: [Constants.Bluetooth.ProteGOServiceUUID], options: nil)
        }
    }

    private func stopScanningIfNeeded() {
        logger.debug("Stopping scanning...")

        // Stop scanning background task
        backgroundTask.stop(taskName: scanningTaskID)

        // Stop scanner timer
        self.scanningTimer?.invalidate()
        self.scanningTimer = nil

        // Check scanning mode
        switch self.mode {
        case .disabled:
            // Stop scanning
            break
        case .enabledAllTime:
            // Don't allow to stop scanning as it should be enabled all time.
            logger.debug("Scanner failed to stop as it's forced to be turned on")
            return
        case let .enabledPartTime(scanningOnTime: _, scanningOffTime: offTime):
            // Setup timer to start scanner after a while
            let timer = Timer.init(timeInterval: offTime, repeats: false) { [weak self] _ in
                self?.startScanningIfNeeded()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.scanningTimer = timer
        }

        // Stop scanning if needed.
        if self.centralManager.state == .poweredOn && self.centralManager.isScanning {
            self.centralManager.stopScan()
        }
    }

    // State management ---------------------------------------------------------------

    /// When state is restored make sure to continue processing.
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        logger.debug("CentralManager restored state")
        let connectedPeripherals: [CBPeripheral]? =
            dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]

        guard let peripherals = connectedPeripherals else {
            return
        }

        // Add known and connected peripherals
        for peripheral in peripherals {
            deviceFound(peripheral: peripheral, rssi: nil, manufacturerData: nil)
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            logger.debug("PoweredOn")
            // We can now use central manager functionality.
            self.startScanningIfNeeded()
        } else {
            logger.debug("PoweredOff: \(central.state.rawValue)")
            // We can assume that peripherals are no longer connecting or connected.
            self.cancelSynchronization(onlyOnTimeout: false)
        }
    }

    // Connection management ----------------------------------------------------------

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.debug("CentralManager did connect: \(peripheral.identifier)")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            handle(event: .Connected(peripheral), for: device)
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.debug("CentralManager did fail to connect: \(peripheral.identifier) error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            handle(event: .Disconnected(peripheral, error), for: device)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.debug("CentralManager did disconnect peripheral \(peripheral.identifier) error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            handle(event: .Disconnected(peripheral, error), for: device)
        }
    }

    // Discovery ----------------------------------------------------------------------

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        logger.debug("CentralManager did discover \(peripheral.identifier) rssi: \(RSSI)")
        let manufacturerData: Data? = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        deviceFound(peripheral: peripheral, rssi: RSSI.intValue, manufacturerData: manufacturerData)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logger.debug("Peripheral did discover services: \(peripheral.identifier), error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            handle(event: .DiscoveredServices(error), for: device)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        logger.debug("Peripheral did modify services: \(peripheral.identifier)")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            handle(event: .DiscoveredServices(nil), for: device)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        logger.debug("Peripheral did discover characteristics: " +
                     "\(peripheral.identifier), error: \(String(describing: error))")

        if let device = self.getDeviceBy(peripheral: peripheral),
               service.uuid == Constants.Bluetooth.ProteGOServiceUUID {
            handle(event: .DiscoveredCharacteristics(service, error), for: device)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        logger.debug("Peripheral did read RSSI: " +
                     "\(peripheral.identifier), rssi: \(RSSI), error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral), error == nil {
            handle(event: .ReadRSSI(peripheral, RSSI.intValue), for: device)
        }
    }

    // Reading value --------------------------------------------------------------------------------

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        logger.debug("Peripheral did read value: \(peripheral.identifier), error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral),
               characteristic.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID {
            handle(event: .ReadValue(characteristic, error), for: device)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        logger.debug("Peripheral did write value: \(peripheral.identifier), error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral),
               characteristic.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID {
            handle(event: .WroteValue(characteristic, error), for: device)
        }
    }
}
