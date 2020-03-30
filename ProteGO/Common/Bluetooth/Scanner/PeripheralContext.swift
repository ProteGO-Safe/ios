import Foundation
import CoreBluetooth

/// This class provides information about the peripheral which was discovered by
/// a central manager.
class PeripheralContext {
    /// Handle to CBPeripheral
    let peripheral: CBPeripheral
    /// Last synchronization date if specified
    var lastSynchronizationDate: Date?
    /// Last connection attempt date if specified
    var lastConnectionDate: Date?
    /// Number of connection retries.
    var connectionRetries = 0
    /// Last RSSI value
    var lastRSSI: Int?
    /// Current state
    var state: PeripheralState = .Idle

    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    /// Defines if peripheral is ready to connect.
    public func readyToConnect() -> Bool {
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

    /// Function specifies if this peripheral has higher priority in the next connection attempt.
    /// - Parameter other: Other peripheral state
    func hasHigherPriorityForConnection(other: PeripheralContext) -> Bool {
        // We check in following order (from most important to less important):

        // Current connection state
        let idle = self.state.isIdle()
        let otherIdle = other.state.isIdle()
        guard idle == otherIdle else {
            // Idle peripheral has higher priority
            return idle
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
