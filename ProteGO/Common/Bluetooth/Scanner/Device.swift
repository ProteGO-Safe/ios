import Foundation
import CoreBluetooth

/// This class provides information about the device which was discovered by
/// a central manager. Only device ID is a stable value.
class Device {
    /// Unique device identfier
    private let id: DeviceId
    /// Handle to current CBPeripheral
    private var peripheral: CBPeripheral
    /// Last discovered device. There is a chance that device with the same ID was
    /// discovered with different mac address, while current connection is in progress.
    /// Make sure to remember the handle for later use.
    private var lastDiscoveredPeripheral: CBPeripheral?
    /// Last successful synchronization date if specified. We use that value to block
    /// further connection attempts.
    private var lastSynchronizationDate: Date?
    /// Last connection attempt date if specified. It is used to cancel connections to devices
    /// which don't manage to finish synchronization procedure in time.
    private var lastConnectionDate: Date?
    /// Number of connection retries, exceeding certain value will mark this device as lost.
    private var connectionRetries = 0
    /// Last RSSI value
    private var lastRSSI: Int?
    /// Current synchronization state
    private var state: DeviceState = .Idle

    init(id: DeviceId, peripheral: CBPeripheral) {
        self.id = id
        self.peripheral = peripheral
    }

    func getId() -> DeviceId {
        self.id
    }

    func getLastRSSI() -> Int? {
        self.lastRSSI
    }

    func isIdle() -> Bool {
        self.state.isIdle()
    }

    func updateDeviceWith(peripheral: CBPeripheral, rssi: Int?) -> CBPeripheral? {
        self.lastRSSI = rssi

        // No need to update if peripheral is the same.
        guard peripheral != self.peripheral else {
            return nil
        }

        // If last peripheral is the same as a new one, ignore
        if let lastPeripheral = self.lastDiscoveredPeripheral, lastPeripheral == peripheral {
            return nil
        }

        // Update peripheral
        let closedPeripheral = self.lastDiscoveredPeripheral
        self.lastDiscoveredPeripheral = peripheral
        return closedPeripheral
    }

    func isPeripheralActive(peripheral: CBPeripheral) -> Bool {
        return self.peripheral == peripheral
    }

    /// Defines if peripheral is ready to connect.
    func isReadyToConnect() -> Bool {
        // Make sure that we are in idle state
        guard self.state.isIdle() else {
            return false
        }

        // If there were connection attempts to this device, wait for a
        // time when we can connect.
        if let lastConnectionDate = self.lastConnectionDate, self.connectionRetries != 0 {
            let nextReconnectionTime = lastConnectionDate.addingTimeInterval(
                TimeInterval(DebugMenu.assign(DebugMenu.bluetoothSynchronizationTimeout))
            )
            if nextReconnectionTime > Date() {
                return false
            }
        }

        // If we never synced with this device, let's do it.
        guard let lastSyncDate = self.lastSynchronizationDate else {
            return true
        }

        // Check if we are ready for the next connection attempt.
        let ignoreTimeout = TimeInterval(DebugMenu.assign(DebugMenu.bluetoothDeviceIgnoredTimeout))
        return lastSyncDate.addingTimeInterval(ignoreTimeout) < Date()
    }

    /// Function specifies if this device has higher priority in the next connection attempt.
    /// - Parameter other: Other device's state
    func hasHigherPriorityForConnection(other: Device) -> Bool {
        // We check in following order (from most important to less important):

        // Current connection state
        let idle = self.state.isIdle()
        let otherIdle = other.state.isIdle()
        guard idle == otherIdle else {
            // Idle peripheral has higher priority
            return idle
        }

        // Device type. Devices with BeaconId are more prone to be lost quickly.
        guard self.id.hasBeaconId() == other.id.hasBeaconId() else {
            // Having Beacon ID gives priority.
            return self.id.hasBeaconId()
        }

        // Connection retries
        guard connectionRetries == other.connectionRetries else {
            // If we have lower number of connection retries, we have higher priority.
            return connectionRetries < other.connectionRetries
        }

        // Last synchronization time
        let syncTime = self.lastSynchronizationDate?.timeIntervalSince1970 ?? 0
        let otherSyncTime = other.lastSynchronizationDate?.timeIntervalSince1970 ?? 0
        guard syncTime == otherSyncTime else {
            // If our sync time is older, we have got priority.
            return syncTime < otherSyncTime
        }

        // RSSI
        let RSSI = self.lastRSSI ?? Int.min
        let otherRSSI = other.lastRSSI ?? Int.min

        // Higher value means better signal.
        return RSSI >= otherRSSI
    }

    func handleEvent(_ event: DeviceEvent) -> [DeviceEffect] {
        var effects: [DeviceEffect] = []

        if case .StartSynchronization = event {
            effects.append(contentsOf: self.startSynchronization())
        }

        if case let .CancelSynchronization(onlyOnTimeout) = event {
            var cancel = !onlyOnTimeout
            if let date = self.lastConnectionDate, onlyOnTimeout {
                let syncTimeout = TimeInterval(DebugMenu.assign(DebugMenu.bluetoothSynchronizationTimeout))
                if date.addingTimeInterval(syncTimeout) < Date() {
                    cancel = true
                }
            }
            if !cancel {
                return []
            }

            effects.append(contentsOf: self.stopSynchronization())
        }

        // Synchronize state with periphera's state.
        synchronizeWithPeripheralState()

        // Handle events based on state value
        let (newState, newEffects) = self.state.handleEvent(event)
        self.state = newState
        effects.append(contentsOf: newEffects)

        // Check if synchronization is finished.
        if case .SynchronizationFinished = self.state {
            effects.append(contentsOf: self.stopSynchronization())
        }

        return effects
    }

    /// Starts new synchronization
    /// - Returns: Effects to execute.
    private func startSynchronization() -> [DeviceEffect] {
        var effects: [DeviceEffect] = []

        // Make sure to stop previous synchronization
        effects.append(contentsOf: self.stopSynchronization())
        if case .Closed = self.state {
            // Don't start synchronization on already closed device
            return effects
        }

        // Reset state to initial value
        self.state = .Queued(self.peripheral)
        self.lastConnectionDate = Date()

        // Check if we received new peripheral, close old one
        // and start using a new one.
        if let newPeripheral = self.lastDiscoveredPeripheral, newPeripheral != peripheral {
            effects.append(.Close(self.peripheral))
            self.peripheral = newPeripheral
            self.lastDiscoveredPeripheral = nil
        }

        return effects
    }

    /// Stop synchronization and check if previous attempt was succesfull
    /// - Returns: Effects to execute
    private func stopSynchronization() -> [DeviceEffect] {
        var effects: [DeviceEffect] = []
        var previousSyncFinished = false

        // If not in idle state, disconnect
        if !self.state.isIdle() {
            effects.append(.Disconnect(peripheral))
        }

        // Check if we had valid synchronization.
        if let beaconId = self.state.getSynchronizedBeaconId() {
            effects.append(.SynchronizeBeaconId(beaconId))
            previousSyncFinished = true
        }

        // Check connection retries to decide if we should
        // close the device.
        if previousSyncFinished || self.state.isIdle() {
            self.state = .Idle
            if previousSyncFinished {
                self.lastSynchronizationDate = Date()
                self.connectionRetries = 0
            }
        } else {
            let maxConnectionRetries =
                self.id.hasBeaconId() ? 0 : DebugMenu.assign(DebugMenu.bluetoothMaxConnectionRetries)
            if self.connectionRetries >= maxConnectionRetries {
                self.state = .Closed
                effects.append(.Close(self.peripheral))
                effects.append(.Remove)
            } else {
                self.connectionRetries += 1
                self.state = .Idle
            }
        }

        // Update other params
        self.lastRSSI = nil

        return effects
    }

    private func synchronizeWithPeripheralState() {
        // Get information about the peripheral
        let peripheral = self.peripheral
        let connected = self.peripheral.state == .connected
        let discoveredService = peripheral.services?.first {
            $0.uuid == Constants.Bluetooth.ProteGOServiceUUID
        }
        let discoveredCharacteristic = discoveredService?.characteristics?.first {
            $0.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID
        }

        // Check if we are already connected.
        if case .Queued = self.state, connected {
            self.state = .Connected(peripheral)
        }
        if case .Connecting = self.state, connected {
            self.state = .Connected(peripheral)
        }

        // Check if we have service
        if case .Connected = self.state, let service = discoveredService {
            self.state = .DiscoveredService(service)
        }
        if case .DiscoveringService = self.state, let service = discoveredService {
            self.state = .DiscoveredService(service)
        }

        // Check if we have characteristic
        if case .DiscoveredService = self.state, let characteristic = discoveredCharacteristic {
            self.state = .DiscoveredCharacteristic(characteristic)
        }
        if case .DiscoveringCharacteristic = self.state, let characteristic = discoveredCharacteristic {
            self.state = .DiscoveredCharacteristic(characteristic)
        }
    }
}

extension Device: CustomStringConvertible {
    var description: String {
        return "[id=\(id), state=\(state), retries=\(connectionRetries)]"
    }
}
