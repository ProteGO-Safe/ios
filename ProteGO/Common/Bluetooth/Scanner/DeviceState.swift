import Foundation
import CoreBluetooth

/// This enum describes connection flow of the device. All steps
/// are executed in sequence specified below.
enum PeripheralState {
    case Idle
    case Queued
    case Connecting
    case Connected
    case DiscoveringService
    case DiscoveredService(CBService)
    case DiscoveringCharacteristic
    case DiscoveredCharacteristic(CBCharacteristic)
    case ReadingCharacteristic

    func isIdle() -> Bool {
        if case .Idle = self {
            return true
        }
        return false
    }
}
