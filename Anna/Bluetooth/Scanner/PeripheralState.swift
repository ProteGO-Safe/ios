import Foundation
import CoreBluetooth

enum PeripheralState {
    case Idle
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
