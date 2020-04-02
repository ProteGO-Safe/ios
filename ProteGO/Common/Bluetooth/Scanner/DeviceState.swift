import Foundation
import CoreBluetooth

/// This enum describes connection flow of the device. All steps
/// are executed in sequence specified below.
enum DeviceState {
    /// Device is closed and should no longer be used. It can be closed due to
    /// maxium allowed connection attempts.
    case Closed
    /// Device is ready to be synchronized.
    case Idle
    /// Device is queued for synchronization.
    case Queued(CBPeripheral)
    /// Device is actively connecting to underlying device.
    case Connecting(CBPeripheral)
    /// Device just connected to underlying device.
    case Connected(CBPeripheral)
    /// Device is discovering ProteGO services.
    case DiscoveringService(CBPeripheral)
    /// Device just discovered ProteGo service.
    case DiscoveredService(CBService)
    /// Device is discovering ProteGO characteristic
    case DiscoveringCharacteristic(CBService)
    /// Device discovered ProteGo characteristic
    case DiscoveredCharacteristic(CBCharacteristic)
    /// Device is reading Beacon ID
    case ReadingBeaconId(CBCharacteristic)
    /// Device succesfully synchronized Beacon ID.
    case SynchronizedBeaconId(CBCharacteristic, BeaconId)
    /// Scanner is writing it's own Beacon ID to connected device.
    case WritingBeaconId(CBCharacteristic, BeaconId)
    /// Synchronization finished. If Beacon ID is specified, synchronization was
    /// successful.
    case SynchronizationFinished(BeaconId?)

    /// Checks if device is in idle state.
    /// - Returns: True if device is idle.
    func isIdle() -> Bool {
        if case .Idle = self {
            return true
        }
        return false
    }

    /// Check if device was in a phase which succesfully retrieved Beacon ID.
    /// - Returns: Synchronized Beacon ID if available.
    func getSynchronizedBeaconId() -> BeaconId? {
        switch self {
        case let .SynchronizedBeaconId(_, beaconId):
            return beaconId
        case let .WritingBeaconId(_, beaconId):
            return beaconId
        case let .SynchronizationFinished(beaconId):
            return beaconId
        default:
            return nil
        }
    }

    /// Handle an event a do a state transition with side effects.
    /// - Parameter event: Triggered event
    /// - Returns: New device state and list of side effects.
    //swiftlint:disable:next function_body_length
    func handleEvent(_ event: DeviceEvent) -> (DeviceState, [DeviceEffect]) {
        switch (self, event) {

        // Ignore events in idle state
        case (.Idle, _):
            return (self, [])

        // Ignore events in closed state
        case (.Closed, _):
            return (self, [])

        // When queued, we connect to peripheral
        case let (.Queued(peripheral), _):
            return (.Connecting(peripheral), [.Connect(peripheral)])

        // When connecting wait for connected event and start discovery
        case let (.Connecting, .Connected(peripheral)):
            return (.DiscoveringService(peripheral), [.DiscoverServices(peripheral)])

        // When connected, start discovery.
        case let (.Connected(peripheral), _):
            return (.DiscoveringService(peripheral), [.DiscoverServices(peripheral)])

        // When discovering services, wait for a service
        case let (.DiscoveringService(peripheral), .DiscoveredServices(error)):
            // On error, just disconnect.
            guard error == nil else {
                return (.SynchronizationFinished(nil), [])
            }
            // If found ProteGO service, continue...
            let proteGOService = peripheral.services?.first { $0.uuid == Constants.Bluetooth.ProteGOServiceUUID }
            if let proteGOService = proteGOService {
                return (.DiscoveringCharacteristic(proteGOService), [.DiscoverCharacteristics(proteGOService)])
            }
            // Wait for service modification...
            return (self, [])

        // When discovered services, continue with discovering characteristic.
        case let (.DiscoveredService(service), _):
            return (.DiscoveringCharacteristic(service), [.DiscoverCharacteristics(service)])

        // When discovering characteristics, wait for discovered event.
        case let (.DiscoveringCharacteristic, .DiscoveredCharacteristics(service, error)):
            // On error, just disconnect
            guard error == nil else {
                return (.SynchronizationFinished(nil), [])
            }

            // If found characteristic, continue
            let proteGOCharacteristic = service.characteristics?.first {
                $0.uuid == Constants.Bluetooth.ProteGOCharacteristicUUID
            }
            if let proteGOCharacteristic = proteGOCharacteristic {
                return (.ReadingBeaconId(proteGOCharacteristic),
                        [.ReadValue(proteGOCharacteristic),
                         .ReadRSSI(proteGOCharacteristic.service.peripheral)])
            }

            // Wait for service modification...
            return (self, [])

        // When discovered characteristic, read BeaconID.
        case let (.DiscoveredCharacteristic(characteristic), _):
            return (.ReadingBeaconId(characteristic),
                    [.ReadValue(characteristic),
                     .ReadRSSI(characteristic.service.peripheral)])

        // When reading characteristic, wait for value.
        case let (.ReadingBeaconId, .ReadValue(characteristic, error)):
            // On error, disconnect.
            guard error == nil else {
                return (.SynchronizationFinished(nil), [])
            }

            // If value was read properly, continue. Data will be actually synchronized
            // when device finishes whole synchronization procedure or when it's aborted.
            if let data = characteristic.value, let beaconId = BeaconId(data: data) {
                return (.WritingBeaconId(characteristic, beaconId), [.WriteValue(characteristic)])
            }

            // We encountered an error, disconnect.
            return (.SynchronizationFinished(nil), [])

        // If synchronized value, let's try writing our own Beacon ID.
        case let (.SynchronizedBeaconId(characteristic, beaconId), _):
            return (.WritingBeaconId(characteristic, beaconId), [.WriteValue(characteristic)])

        // If writing Beacon ID, wait for confirmation.
        case let (.WritingBeaconId(_, beaconId), .WroteValue):
            // Regardless of a result finish synchronization
            return (.SynchronizationFinished(beaconId), [])

        // In case of disconnection, finish synchronization.
        case (_, .Disconnected):
            return (.SynchronizationFinished(self.getSynchronizedBeaconId()), [])

        // Ignore other cases
        default:
            return (self, [])
        }
    }
}

extension DeviceState: CustomStringConvertible {
    var description: String {
        switch self {
        case .Closed:
            return "Closed"
        case .Idle:
            return "Idle"
        case .Queued:
            return "Queued"
        case .Connecting:
            return "Connecting(..)"
        case .Connected:
            return "Connected(..)"
        case .DiscoveringService:
            return "DiscoveringService(..)"
        case .DiscoveredService:
            return "DiscoveredService(..)"
        case .DiscoveringCharacteristic:
            return "DiscoveringCharacteristic(..)"
        case .DiscoveredCharacteristic:
            return "DiscoveredCharacteristic(..)"
        case .ReadingBeaconId:
            return "ReadingBeaconId(..)"
        case let .SynchronizedBeaconId(_, beaconId):
            return "SynchronizedBeaconId(_, \(beaconId))"
        case let .WritingBeaconId(_, beaconId):
            return "WritingBeaconId(_, \(beaconId))"
        case let .SynchronizationFinished(beaconId):
            return "SynchronizationFinished(\(String(describing: beaconId)))"
        }
    }
}
