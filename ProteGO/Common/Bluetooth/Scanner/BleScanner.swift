import Foundation
import CoreBluetooth

class BleScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, Scanner {
    /// CBCentral manager
    private var centralManager: CBCentralManager!

    /// Delegate to tell about events.
    private weak var delegate: ScannerDelegate?

    /// List of known peripherals with their state
    private var peripherals: [CBPeripheral: PeripheralContext]

    /// Scanning restart timer. After a timeout we restart scanning.
    private var scanningRestartTimer: Timer?
    /// Scanning stop timer. After a timeout we stop scanning.
    private var scanningStopTimer: Timer?

    /// Background task handle
    private let backgroundTask: BluetoothBackgroundTask
    private let scanningTaskID = Constants.Bluetooth.ScanningBackgroundTaskID

    /// Initialize Central Manager with restored state identifier to be able to work in the background.
    init(delegate: ScannerDelegate, backgroundTask: BluetoothBackgroundTask) {
        self.backgroundTask = backgroundTask
        self.peripherals = [:]
        super.init()
        self.delegate = delegate

        let options = [CBCentralManagerOptionRestoreIdentifierKey: Constants.Bluetooth.ProteGOServiceUUID]
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

    // swiftlint:disable function_body_length
    /// Depending on the peripheral state, invoke actions to finalize synchronization.
    /// - Parameter peripheralContext: peripheral's context
    private func proceedWithPeripheralSynchronization(peripheralContext: PeripheralContext) {
        logger.debug("Proceeding with synchronization: " +
                     " \(peripheralContext.peripheral.identifier): \(peripheralContext.state)")

        // Make sure we are in PoweredOn state
        guard centralManager.state == .poweredOn else {
            peripheralFailedToSynchronize(peripheralContext: peripheralContext)
            return
        }

        // Gather info about the peripheral
        let peripheral = peripheralContext.peripheral
        let connected = peripheralContext.peripheral.state == .connected
        let discoveredService = peripheral.services?.first { $0.uuid == Constants.Bluetooth.ProteGOServiceUUID }
        let discoveredCharacteristic = discoveredService?.characteristics?.first {
            $0.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID
        }

        // Handle each state properly. We don't use switch statement as it's not posssible
        // to fallthrough with bind variables?
        if case .Idle = peripheralContext.state {
            // Check if we need to connect.
            if !connected {
                peripheralContext.state = .Connecting
                centralManager.connect(peripheral, options: nil)
                return
            } else {
                // We are already connected for some reason.
                peripheralContext.state = .Connected
            }
        }

        if case .Connecting = peripheralContext.state {
            if !connected {
                // If we are still not connected, wait for it.
                return
            } else {
                // We are already connected for some reason.
                peripheralContext.state = .Connected
            }
        }

        if case .Connected = peripheralContext.state {
            // Try to get RSSI value
            peripheral.readRSSI()
            if let service = discoveredService {
                // If service is already discovered let's continue...
                peripheralContext.state = .DiscoveredService(service)
            } else {
                // We need to discover service
                peripheral.discoverServices([Constants.Bluetooth.ProteGOServiceUUID])
                peripheralContext.state = .DiscoveringService
                return
            }
        }

        if case .DiscoveringService = peripheralContext.state {
            if let service = discoveredService {
                // If service is already discovered let's continue...
                peripheralContext.state = .DiscoveredService(service)
            } else {
                // Wait for discovery to finish...
                return
            }
        }

        if case let .DiscoveredService(service) = peripheralContext.state {
            if let characteristic = discoveredCharacteristic {
                // Characteristic was already discovered
                peripheralContext.state = .DiscoveredCharacteristic(characteristic)
            } else {
                // Let's discover characteristic
                peripheral.discoverCharacteristics([Constants.Bluetooth.ProteGOCharacteristicUUID], for: service)
                peripheralContext.state = .DiscoveringCharacteristic
                return
            }
        }

        if case .DiscoveringCharacteristic = peripheralContext.state {
            if let characteristic = discoveredCharacteristic {
                // Characteristic was already discovered
                peripheralContext.state = .DiscoveredCharacteristic(characteristic)
            } else {
                // Wait for discovery to finish
                return
            }
        }

        if case let .DiscoveredCharacteristic(characteristic)  = peripheralContext.state {
            peripheral.readValue(for: characteristic)
            peripheralContext.state = .ReadingCharacteristic
            return
        }

        if case .ReadingCharacteristic = peripheralContext.state {
            // Wait for result
            return
        }

        logger.debug("Unexpected state: \(peripheralContext.state)")
        peripheralFailedToSynchronize(peripheralContext: peripheralContext)
    }
    // swiftlint:enable function_body_length

    /// Peripheral successfully synchronized.
    /// - Parameters:
    ///   - peripheralContext: Synchronized peripheral.
    ///   - data: Synchronization token data.
    private func peripheralSynchronized(peripheralContext: PeripheralContext, data: Data) {
        logger.debug("Peripheral synchronized: \(peripheralContext.peripheral.identifier) with data: \(data)")

        // Stop task
        backgroundTask.stop(taskName: peripheralContext.peripheral.identifier.uuidString)

        // Cancel connection.
        if centralManager.state == .poweredOn {
            centralManager.cancelPeripheralConnection(peripheralContext.peripheral)
        }

        // Inform about a new token
        delegate?.synchronizedTokenData(data: data, rssi: peripheralContext.lastRSSI)

        // Update peripheral's state
        peripheralContext.connectionRetries = 0
        peripheralContext.lastRSSI = nil
        peripheralContext.lastSynchronizationDate = Date()
        peripheralContext.state = .Idle
    }

    /// Peripheral failed to synchronize due to an error or timeout.
    /// - Parameter peripheralContext: peripheral which failed to synchronize
    private func peripheralFailedToSynchronize(peripheralContext: PeripheralContext) {
        logger.debug("Peripheral failed to synchronize: \(peripheralContext.peripheral.identifier)")

        // Stop task
        backgroundTask.stop(taskName: peripheralContext.peripheral.identifier.uuidString)

        // Cancel connection.
        let isConnected = peripheralContext.peripheral.state == .connected ||
                          peripheralContext.peripheral.state == .connecting
        if isConnected && centralManager.state == .poweredOn {
            centralManager.cancelPeripheralConnection(peripheralContext.peripheral)
        }

        if peripheralContext.connectionRetries >= Constants.Bluetooth.PeripheralMaxConnectionRetries {
            // Remove peripheral until discovered once again.
            self.peripherals.removeValue(forKey: peripheralContext.peripheral)
            peripheralContext.peripheral.delegate = nil
        } else {
            // Update peripheral's state
            peripheralContext.connectionRetries += 1
            peripheralContext.lastRSSI = nil
            peripheralContext.state = .Idle
        }
    }

    /// Peripheral was found by a central manager.
    /// - Parameters:
    ///   - peripheralContext: Detected peripheral
    ///   - rssi: Peripheral's RSSI during discovery.
    private func peripheralFound(peripheralContext: PeripheralContext, rssi: Int?) {
        logger.debug("Peripheral found: \(peripheralContext.peripheral.identifier) rssi: \(String(describing: rssi))")
        // Update peripheral's state
        peripheralContext.lastRSSI = rssi

        // Check if we need to synchronize.
        startSynchronizationIfNeeded()
    }

    /// This method is called when we can't synchronize anymore.
    private func cancelSynchronization(onlyOnTimeout: Bool) {
        logger.debug("Cancelling synchronization, onlyOnTimeout: \(onlyOnTimeout)")
        for peripheral in self.peripherals {
            var cancel = !peripheral.value.state.isIdle()
            if let lastConnectionDate = peripheral.value.lastConnectionDate, cancel && onlyOnTimeout {
                let timeout = Constants.Bluetooth.PeripheralSynchronizationTimeoutInSec
                cancel = lastConnectionDate.addingTimeInterval(timeout) < Date()
            }

            if cancel {
                peripheralFailedToSynchronize(peripheralContext: peripheral.value)
            }
        }
    }

    /// This method is called every time interval to check the state of a connection.
    private func checkSynchronizationStatus() {
        logger.debug("Check synchronization status")

        // Fail synchronization, which took to long.
        cancelSynchronization(onlyOnTimeout: true)

        // Start synchronization if needed
        startSynchronizationIfNeeded()
    }

    /// This function is called when there is an event, which could change state deciding about
    /// need to synchronize.
    private func startSynchronizationIfNeeded() {
        // Make sure we are powered on.
        guard self.centralManager.state == .poweredOn else {
            return
        }

        // Get list of peripherals and sort it by a a connection priority
        let sortedPeripherals = self.peripherals.values.sorted { (a, b) in
            a.hasHigherPriorityForConnection(other: b)
        }

        // Check number of pending connections
        var freeSlots = Constants.Bluetooth.PeripheralMaxConcurrentConnections
        sortedPeripherals.forEach { peripheral in
            // Get debug info
            logger.debug("[id: \(peripheral.peripheral.identifier), " +
                  "state: \(peripheral.state), " +
                  "retries: \(peripheral.connectionRetries)]")

            // Remove from slot if peripheral is not idle.
            if !peripheral.state.isIdle() && freeSlots > 0 {
                freeSlots -= 1
            }
        }

        // If ready to connect, let's start synchronization.
        for i in 0..<freeSlots where i < sortedPeripherals.count {
            let peripheral = sortedPeripherals[i]
            if peripheral.readyToConnect() {
                // Start background task.
                backgroundTask.start(taskName: peripheral.peripheral.identifier.uuidString)

                // Start synchronization.
                peripheral.lastConnectionDate = Date()
                proceedWithPeripheralSynchronization(peripheralContext: peripheral)
            }
        }
    }

    private func startScanningIfNeeded() {
        logger.debug("Start scanning")

        // Start scanning background task
        backgroundTask.start(taskName: scanningTaskID)

        // Restart scanning stop timer.
        self.scanningStopTimer?.invalidate()
        let newScanningStopTimer = Timer.init(
            timeInterval: Constants.Bluetooth.ScanningStopTimeout,
            repeats: false) { [weak self] _ in
                self?.stopScanningIfNeeded()
        }
        RunLoop.main.add(newScanningStopTimer, forMode: .common)
        self.scanningStopTimer = newScanningStopTimer

        // Restart scanning restart timer.
        self.scanningRestartTimer?.invalidate()
        let newScanningRestartTimer = Timer.init(
            timeInterval: Constants.Bluetooth.ScanningRestartTimeout,
            repeats: false) { [weak self] _ in
                self?.startScanningIfNeeded()
        }
        RunLoop.main.add(newScanningRestartTimer, forMode: .common)
        self.scanningRestartTimer = newScanningRestartTimer

        // Start scanning if needed.
        if !self.centralManager.isScanning {
            self.centralManager.scanForPeripherals(withServices: [Constants.Bluetooth.ProteGOServiceUUID], options: nil)
        }
    }

    private func stopScanningIfNeeded() {
        logger.debug("Stop scanning")

        // Stop scanning background task
        backgroundTask.stop(taskName: scanningTaskID)

        // Stop scanning if needed.
        if self.centralManager.isScanning {
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
            peripheral.delegate = self
            self.peripherals[peripheral] = PeripheralContext(peripheral: peripheral)
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
            cancelSynchronization(onlyOnTimeout: false)
        }
    }

    // Connection management ----------------------------------------------------------

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.debug("CentralManager did connect: \(peripheral.identifier)")
        if let peripheralContext = self.peripherals[peripheral] {
            peripheralContext.state = .Connected
            proceedWithPeripheralSynchronization(peripheralContext: peripheralContext)
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.debug("CentralManager did fail to connect: \(peripheral.identifier) error: \(String(describing: error))")
        if let peripheralContext = self.peripherals[peripheral] {
            peripheralFailedToSynchronize(peripheralContext: peripheralContext)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.debug("CentralManager did disconnect peripheral \(peripheral.identifier) error: \(String(describing: error))")
        if let peripheralContext = self.peripherals[peripheral] {
            if error != nil {
                peripheralFailedToSynchronize(peripheralContext: peripheralContext)
            }
        }
    }

    // Discovery ----------------------------------------------------------------------

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        logger.debug("CentralManager did discover \(peripheral.identifier) rssi: \(RSSI)")
        if let peripheralContext = self.peripherals[peripheral] {
            peripheralFound(peripheralContext: peripheralContext, rssi: RSSI.intValue)
        } else {
            peripheral.delegate = self
            let peripheralContext = PeripheralContext(peripheral: peripheral)
            self.peripherals[peripheral] = peripheralContext
            peripheralFound(peripheralContext: peripheralContext, rssi: RSSI.intValue)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logger.debug("Peripheral did discover services: \(peripheral.identifier), error: \(String(describing: error))")
        if let peripheralContext = self.peripherals[peripheral] {
            if error == nil {
                proceedWithPeripheralSynchronization(peripheralContext: peripheralContext)
            } else {
                peripheralFailedToSynchronize(peripheralContext: peripheralContext)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        logger.debug("Peripheral did modify services: \(peripheral.identifier)")
        if let peripheralContext = self.peripherals[peripheral], !peripheralContext.state.isIdle() {
            proceedWithPeripheralSynchronization(peripheralContext: peripheralContext)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        logger.debug("Peripheral did discover characteristics: " +
                     "\(peripheral.identifier), error: \(String(describing: error))")

        if let peripheralContext = self.peripherals[peripheral], service.uuid == Constants.Bluetooth.ProteGOServiceUUID {
            if error == nil {
                proceedWithPeripheralSynchronization(peripheralContext: peripheralContext)
            } else {
                peripheralFailedToSynchronize(peripheralContext: peripheralContext)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        logger.debug("Peripheral did read RSSI: " +
                     "\(peripheral.identifier), rssi: \(RSSI), error: \(String(describing: error))")
        if let peripheralContext = self.peripherals[peripheral], error == nil {
            peripheralContext.lastRSSI = RSSI.intValue
        }
    }

    // Reading value --------------------------------------------------------------------------------

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        logger.debug("Peripheral did read value: \(peripheral.identifier), error: \(String(describing: error))")
        if let peripheralContext = self.peripherals[peripheral],
           characteristic.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID {
            if let data = characteristic.value, error == nil {
                peripheralSynchronized(peripheralContext: peripheralContext, data: data)
            } else {
                peripheralFailedToSynchronize(peripheralContext: peripheralContext)
            }
        }
    }
}
