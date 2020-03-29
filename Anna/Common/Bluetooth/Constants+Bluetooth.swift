import Foundation
import CoreBluetooth

public extension Constants {
    class Bluetooth {
        /// Anna Service contained in GATT
        static let AnnaServiceUUIDString = "89a60000-4f57-4c1b-9042-7ed87d723b4e"
        static let AnnaServiceUUID = CBUUID(string: AnnaServiceUUIDString)

        /// Anna Characteristic contained in GATT
        static let AnnaCharacteristicUUIDString = "89a60001-4f57-4c1b-9042-7ed87d723b4e"
        static let AnnaCharacteristicUUID = CBUUID(string: AnnaCharacteristicUUIDString)

        /// Time after which we check if connections health
        static let PeripheralSynchronizationCheckInSec: TimeInterval = 5

        /// Synchronization timeout for a peripheral in seconds. Defines how long we should wait for established connection,
        /// discovery and reading value before we decide to cancel our attempt.
        static let PeripheralSynchronizationTimeoutInSec: TimeInterval = 15

        /// Peripheral ignored timeout in seconds. Defines how long we want to restrict connection attempts to this
        /// device when synchronization was already completed.
        static let PeripheralIgnoredTimeoutInSec: TimeInterval = 60

        /// Define how long we should wait before we attempt to reconnect to the device, which failed to synchronize.
        static let PeripheralReconnectionTimeoutPerAttemptInSec: TimeInterval = 5

        /// Maxium number of concurrent connections established by a peripheral manager.
        static let PeripheralMaxConcurrentConnections = 3

        /// Maximum number of connection retries before we decide to remove device until discovered once again.
        static let PeripheralMaxConnectionRetries = 3
    }
}
