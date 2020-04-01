import Foundation

enum AdvertiserMode {
    case Disabled
    case EnabledAllTime
    case EnabledPartTime(advertisingOnTime: TimeInterval,
                         advertisingOffTime: TimeInterval)
}
