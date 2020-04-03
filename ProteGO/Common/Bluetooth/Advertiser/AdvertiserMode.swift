import Foundation

enum AdvertiserMode {
    case disabled
    case enabledAllTime
    case enabledPartTime(advertisingOnTime: TimeInterval,
                         advertisingOffTime: TimeInterval)
}
