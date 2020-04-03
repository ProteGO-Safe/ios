import Foundation

enum ScannerMode {
    case disabled
    case enabledAllTime
    case enabledPartTime(scanningOnTime: TimeInterval,
                         scanningOffTime: TimeInterval)
}
