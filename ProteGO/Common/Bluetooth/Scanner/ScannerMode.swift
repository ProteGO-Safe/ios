import Foundation

enum ScannerMode {
    case Disabled
    case EnabledAllTime
    case EnabledPartTime(scanningOnTime: TimeInterval,
                         scanningOffTime: TimeInterval)
}
