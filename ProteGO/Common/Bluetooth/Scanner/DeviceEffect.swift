import Foundation
import CoreBluetooth

/// Device effect to execute by the scanner.
enum DeviceEffect {
    /// Remove current device from the list of known devices as we
    /// reached a limit of allowed connection attemps.
    case Remove
    /// Close underlying peripheral as it's no longer used.
    case Close(CBPeripheral)
    /// Connect to underlying peripheral.
    case Connect(CBPeripheral)
    /// Disconnect from peripheral as connection is no longer needed.
    case Disconnect(CBPeripheral)
    /// Discover ProteGO services of the underlying peripheral.
    case DiscoverServices(CBPeripheral)
    /// Discover ProteGO characteristic(s) of the underlying service.
    case DiscoverCharacteristics(CBService)
    /// Read ProteGO characteristic value.
    case ReadValue(CBCharacteristic)
    /// Write ProteGO characteristic value.
    case WriteValue(CBCharacteristic)
    /// Read RSSI of the device.
    case ReadRSSI(CBPeripheral)
    /// Beacon ID was fetched from device. Let's synchronize it.
    case SynchronizeBeaconId(BeaconId)
}

extension DeviceEffect: CustomStringConvertible {
    var description: String {
        switch self {
        case .Remove:
            return "Remove"
        case let .Close(peripheral):
            return "Close(\(peripheral.identifier))"
        case let .Connect(peripheral):
            return "Connect(\(peripheral.identifier))"
        case let .Disconnect(peripheral):
            return "Disconnect(\(peripheral.identifier))"
        case let .DiscoverServices(peripheral):
            return "DiscoverServices(\(peripheral.identifier))"
        case let .DiscoverCharacteristics(service):
            return "DiscoverCharacteristics(\(service.peripheral.identifier))"
        case let .ReadValue(characteristic):
            return "ReadValue(\(characteristic.service.peripheral.identifier))"
        case let .WriteValue(characteristic):
            return "WriteValue(\(characteristic.service.peripheral.identifier))"
        case let .ReadRSSI(peripheral):
            return "ReadRSSI(\(peripheral.identifier))"
        case let .SynchronizeBeaconId(beaconId):
            return "SynchronizeBeaconId(\(beaconId))"
        }
    }
}
