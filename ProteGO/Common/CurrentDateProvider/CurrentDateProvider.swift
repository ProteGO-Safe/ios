import Foundation

final class CurrentDateProvider: CurrentDateProviderType {
    var currentDate: Date {
        Date()
    }
}
