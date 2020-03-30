import Foundation
import CoreBluetooth

extension Constants {
    class Bluetooth {
        /// Bluetooth background task ID.
        static let BackgroundTaskID = "pl.gov.anna.BluetoothBackgroundTask"
        /// Bluetooth background task earliest start time
        static let BackgroundTaskEarliestBeginDate: TimeInterval = 15 * 60
        /// Bluetooth advertising task ID
        static let AdvertisingBackgroundTaskID = "bluetooth.advertiser"
        /// Bluetooth scanning task ID
        static let ScanningBackgroundTaskID = "bluetooth.scanning"

        /// ProteGO Service contained in GATT
        static let ProteGOServiceUUIDString = "89a60000-4f57-4c1b-9042-7ed87d723b4e"
        static let ProteGOServiceUUID = CBUUID(string: ProteGOServiceUUIDString)

        /// ProteGO Characteristic contained in GATT
        static let ProteGOCharacteristicUUIDString = "89a60001-4f57-4c1b-9042-7ed87d723b4e"
        static let ProteGOCharacteristicUUID = CBUUID(string: ProteGOCharacteristicUUIDString)

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

        /// Advertising restart timeout. After this period of time advertising is resumed.
        static let AdvertisingRestartTimeout: TimeInterval = 60

        /// Advertising stop timeout. After this period of time advertising is stopped.
        static let AdvertisingStopTimeout: TimeInterval = 15

        /// Scanning restart timeout. After this period of time scanning is resumed.
        static let ScanningRestartTimeout: TimeInterval = 60

        /// Scanning stop timeout. After this period of time scanning is stopped.
        static let ScanningStopTimeout: TimeInterval = 15
    }
}
