import Foundation
import CoreBluetooth

class BleScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, Scanner {
    /// CBCentral manager
    private var centralManager: CBCentralManager!

    /// Delegate to tell about events.
    private weak var delegate: ScannerDelegate?

    /// List of known devices with their context
    private var devices: [DeviceId: Device]

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
        self.devices = [:]
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

    /// Depending on the device's state, invoke actions to finalize synchronization.
    /// - Parameter device: device's context
    // swiftlint:disable:next function_body_length
    private func continueDeviceSynchronization(device: Device) {
        logger.debug("Proceeding with synchronization: \(device.id)")

        // Make sure we are in PoweredOn state
        guard centralManager.state == .poweredOn else {
            deviceFailedToSynchronize(device: device)
            return
        }

        // Gather info about the device
        let peripheral = device.peripheral
        let connected = device.peripheral.state == .connected
        let discoveredService = peripheral.services?.first { $0.uuid == Constants.Bluetooth.ProteGOServiceUUID }
        let discoveredCharacteristic = discoveredService?.characteristics?.first {
            $0.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID
        }

        // Don't do anything in Idle state.
        if case .Idle = device.state {
            return
        }

        if case .Queued = device.state {
            // Check if we need to connect.
            if !connected {
                device.state = .Connecting
                centralManager.connect(peripheral, options: nil)
                return
            } else {
                // We are already connected for some reason.
                device.state = .Connected
            }
        }

        if case .Connecting = device.state {
            if !connected {
                // If we are still not connected, wait for it.
                return
            } else {
                // We are already connected for some reason.
                device.state = .Connected
            }
        }

        if case .Connected = device.state {
            // Try to get RSSI value
            peripheral.readRSSI()
            if let service = discoveredService {
                // If service is already discovered let's continue...
                device.state = .DiscoveredService(service)
            } else {
                // We need to discover service
                peripheral.discoverServices([Constants.Bluetooth.ProteGOServiceUUID])
                device.state = .DiscoveringService
                return
            }
        }

        if case .DiscoveringService = device.state {
            if let service = discoveredService {
                // If service is already discovered let's continue...
                device.state = .DiscoveredService(service)
            } else {
                // Wait for discovery to finish...
                return
            }
        }

        if case let .DiscoveredService(service) = device.state {
            if let characteristic = discoveredCharacteristic {
                // Characteristic was already discovered
                device.state = .DiscoveredCharacteristic(characteristic)
            } else {
                // Let's discover characteristic
                peripheral.discoverCharacteristics([Constants.Bluetooth.ProteGOCharacteristicUUID], for: service)
                device.state = .DiscoveringCharacteristic
                return
            }
        }

        if case .DiscoveringCharacteristic = device.state {
            if let characteristic = discoveredCharacteristic {
                // Characteristic was already discovered
                device.state = .DiscoveredCharacteristic(characteristic)
            } else {
                // Wait for discovery to finish
                return
            }
        }

        if case let .DiscoveredCharacteristic(characteristic)  = device.state {
            peripheral.readValue(for: characteristic)
            device.state = .ReadingCharacteristic
            return
        }

        if case .ReadingCharacteristic = device.state {
            // Wait for result
            return
        }

        logger.debug("Unexpected state: \(device.state)")
        deviceFailedToSynchronize(device: device)
    }

    /// Device successfully synchronized.
    /// - Parameters:
    ///   - device: Synchronized device.
    ///   - data: Synchronization beacon id.
    private func deviceSynchronized(device: Device, beaconId: BeaconId) {
        logger.debug("Device synchronized: \(device.id) with beaconId: \(beaconId)")

        // Stop task
        backgroundTask.stop(taskName: device.id.description)

        // Cancel connection.
        if centralManager.state == .poweredOn {
            centralManager.cancelPeripheralConnection(device.peripheral)
        }

        // Inform about a new token
        delegate?.synchronizedBeaconId(beaconId: beaconId, rssi: device.lastRSSI)

        // Update device's state
        device.connectionRetries = 0
        device.lastRSSI = nil
        device.lastSynchronizationDate = Date()
        device.state = .Idle
    }

    /// Device failed to synchronize due to an error or timeout.
    /// - Parameter device: device which failed to synchronize
    private func deviceFailedToSynchronize(device: Device) {
        logger.debug("Device failed to synchronize: \(device.id)")

        // Stop task
        backgroundTask.stop(taskName: device.id.description)

        // Cancel connection.
        let isConnected = device.peripheral.state == .connected ||
                          device.peripheral.state == .connecting
        if isConnected && centralManager.state == .poweredOn {
            centralManager.cancelPeripheralConnection(device.peripheral)
        }

        if device.connectionRetries >= Constants.Bluetooth.PeripheralMaxConnectionRetries {
            // Remove peripheral until discovered once again.
            self.devices.removeValue(forKey: device.id)
            device.peripheral.delegate = nil
        } else {
            // Update peripheral's state
            device.connectionRetries += 1
            device.lastRSSI = nil
            device.state = .Idle
        }
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

        // Create DeviceId base on the manufacturerData
        let deviceId: DeviceId
        if let data = manufacturerData {
            if let beaconId = BeaconId(data: data) {
                deviceId = .BeaconId(beaconId)
            } else {
                deviceId = .IncompleteBeaconId(data)
            }
        } else {
            deviceId = .PeripheralInstance(peripheral)
        }

        // Check if there is a device with this ID
        if let device = self.devices[deviceId] {
            // Update information about the device
            device.lastRSSI = rssi
            if let lastDiscoveredDevice = device.lastDiscoveredPeripheral {
                lastDiscoveredDevice.delegate = nil
            }
            device.lastDiscoveredPeripheral = peripheral
        } else {
            // Create a new device
            let device = Device(id: deviceId, peripheral: peripheral)
            self.devices[deviceId] = device
        }

        // Setup delegate on this peripheral as it will be used
        peripheral.delegate = self

        // Check if we need to synchronize.
        startSynchronizationIfNeeded()
    }

    /// Utility function to find device by an active peripheral instance
    /// - Parameter peripheral: Active peripheral instance of a device
    func getDeviceBy(peripheral: CBPeripheral) -> Device? {
        return self.devices.first { $0.value.peripheral == peripheral }?.value
    }

    /// This method is called when we want to stop synchronization.
    private func cancelSynchronization(onlyOnTimeout: Bool) {
        logger.debug("Cancelling synchronization, onlyOnTimeout: \(onlyOnTimeout)")
        for device in self.devices.values {
            var cancel = device.state.isIdle()
            if let lastConnectionDate = device.lastConnectionDate, cancel && onlyOnTimeout {
                let timeout = Constants.Bluetooth.PeripheralSynchronizationTimeoutInSec
                cancel = lastConnectionDate.addingTimeInterval(timeout) < Date()
            }
            if cancel {
                deviceFailedToSynchronize(device: device)
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

        // Get list of devices and sort it by a a connection priority
        let sortedDevices = self.devices.values.sorted { (a, b) in
            a.hasHigherPriorityForConnection(other: b)
        }

        // Check number of pending connections
        var freeSlots = Constants.Bluetooth.PeripheralMaxConcurrentConnections
        sortedDevices.forEach { device in
            // Get debug info
            logger.debug(device.description)

            // Remove from slot if device is not idle.
            if !device.state.isIdle() && freeSlots > 0 {
                freeSlots -= 1
            }
        }

        // If ready to connect, let's start synchronization.
        for i in 0..<freeSlots where i < sortedDevices.count {
            let device = sortedDevices[i]
            if device.isReadyToConnect() {
                // Start background task.
                backgroundTask.start(taskName: device.id.description)

                // Start synchronization.
                device.lastConnectionDate = Date()
                device.state = .Queued
                continueDeviceSynchronization(device: device)
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
            cancelSynchronization(onlyOnTimeout: false)
        }
    }

    // Connection management ----------------------------------------------------------

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.debug("CentralManager did connect: \(peripheral.identifier)")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            device.state = .Connected
            continueDeviceSynchronization(device: device)
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.debug("CentralManager did fail to connect: \(peripheral.identifier) error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            deviceFailedToSynchronize(device: device)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.debug("CentralManager did disconnect peripheral \(peripheral.identifier) error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            if error != nil {
                deviceFailedToSynchronize(device: device)
            }
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
            if error == nil {
                continueDeviceSynchronization(device: device)
            } else {
                deviceFailedToSynchronize(device: device)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        logger.debug("Peripheral did modify services: \(peripheral.identifier)")
        if let device = self.getDeviceBy(peripheral: peripheral) {
            continueDeviceSynchronization(device: device)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        logger.debug("Peripheral did discover characteristics: " +
                     "\(peripheral.identifier), error: \(String(describing: error))")

        if let device = self.getDeviceBy(peripheral: peripheral),
               service.uuid == Constants.Bluetooth.ProteGOServiceUUID {
            if error == nil {
                continueDeviceSynchronization(device: device)
            } else {
                deviceFailedToSynchronize(device: device)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        logger.debug("Peripheral did read RSSI: " +
                     "\(peripheral.identifier), rssi: \(RSSI), error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral), error == nil {
            device.lastRSSI = RSSI.intValue
        }
    }

    // Reading value --------------------------------------------------------------------------------

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        logger.debug("Peripheral did read value: \(peripheral.identifier), error: \(String(describing: error))")
        if let device = self.getDeviceBy(peripheral: peripheral),
               characteristic.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID {

            if let data = characteristic.value, let beaconId = BeaconId(data: data) {
                deviceSynchronized(device: device, beaconId: beaconId)
            } else {
                deviceFailedToSynchronize(device: device)
            }
        }
    }
}
