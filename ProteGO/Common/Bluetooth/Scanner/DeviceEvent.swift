import Foundation
import CoreBluetooth

/// Device events emitted by scanner, peripheral or central manager.
enum DeviceEvent {
    /// This event starts a synchronization. If synchronization is currently in progress
    /// it will be cancelled beforehand.
    case StartSynchronization
    /// Cancel synchronization. First argument decides if only devices which timed out
    /// should be cancelled.
    case CancelSynchronization(Bool)
    /// Underlying peripheral connected.
    case Connected(CBPeripheral)
    /// Underlying peripheral disconnected. If error is  not `nil` that means that
    /// device disconnected from us.
    case Disconnected(CBPeripheral, Error?)
    /// Underlying peripheral updated RSSI value.
    case ReadRSSI(CBPeripheral, Int)
    /// Underlying peripheral discovered services possibly containing ProteGo services.
    case DiscoveredServices(Error?)
    /// Underlying peripheral discovered characteristics. Provided service is a ProteGO service.
    case DiscoveredCharacteristics(CBService, Error?)
    /// Underlying peripheral read value from ProteGO characteristic.
    case ReadValue(CBCharacteristic, Error?)
    /// Underlying peripheral wrote value to ProteGO characteristic.
    case WroteValue(CBCharacteristic, Error?)
}

extension DeviceEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .StartSynchronization:
            return "StartSynchronization"
        case let .CancelSynchronization(onlyOnTimeout):
            return "CancelSynchronization(\(onlyOnTimeout))"
        case let .Connected(peripheral):
            return "Connected(\(peripheral.identifier))"
        case let .Disconnected(peripheral, error):
            return "Disconnected(\(peripheral.identifier), \(error.debugDescription))"
        case let .ReadRSSI(peripheral, rssi):
            return "ReadRSSI(\(peripheral.identifier), \(rssi))"
        case let .DiscoveredServices(error):
            return "DiscoveredServices(\(error.debugDescription))"
        case let .DiscoveredCharacteristics(service, error):
            return "DiscoveredCharacteristics(\(service.peripheral.identifier), \(error.debugDescription))"
        case let .ReadValue(characteristic, error):
            return "ReadValue(\(characteristic.service.peripheral.identifier), \(error.debugDescription))"
        case let .WroteValue(characteristic, error):
            return "WroteValue(\(characteristic.service.peripheral.identifier), \(error.debugDescription))"
        }
    }
}
