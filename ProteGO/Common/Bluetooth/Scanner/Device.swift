import Foundation
import CoreBluetooth

/// This class provides information about the device which was discovered by
/// a central manager. Only device ID is a stable value.
class Device {
    /// Unique device identfier
    let id: DeviceId
    /// Handle to current CBPeripheral
    var peripheral: CBPeripheral
    /// Last discovered device. There is a chance that device with the same ID was
    /// discovered with different mac address, while current connection is in progress.
    /// Make sure to remember the handle for later use.
    var lastDiscoveredPeripheral: CBPeripheral?
    /// Last successful synchronization date if specified. We use that value to block
    /// further connection attempts.
    var lastSynchronizationDate: Date?
    /// Last connection attempt date if specified. It is used to cancel connections to devices
    /// which don't manage to finish synchronization procedure in time.
    var lastConnectionDate: Date?
    /// Number of connection retries, exceeding certain value will mark this device as lost.
    var connectionRetries = 0
    /// Last RSSI value
    var lastRSSI: Int?
    /// Current synchronization state
    var state: PeripheralState = .Idle

    init(id: DeviceId, peripheral: CBPeripheral) {
        self.id = id
        self.peripheral = peripheral
    }

    /// Defines if peripheral is ready to connect.
    public func isReadyToConnect() -> Bool {
        // Make sure that we are in idle state
        guard self.state.isIdle() else {
            return false
        }

        // If there were connection attempts to this device, wait for a
        // time when we can connect.
        if let lastConnectionDate = self.lastConnectionDate, self.connectionRetries != 0 {
            let nextReconnectionTime = lastConnectionDate.addingTimeInterval(
                Constants.Bluetooth.PeripheralSynchronizationTimeoutInSec +
                Constants.Bluetooth.PeripheralReconnectionTimeoutPerAttemptInSec * Double(self.connectionRetries)
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
        return lastSyncDate.addingTimeInterval(Constants.Bluetooth.PeripheralIgnoredTimeoutInSec) < Date()
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
}

extension Device: CustomStringConvertible {
    var description: String {
        return "[id=\(id), state=\(state), retries=\(connectionRetries)]"
    }
}
